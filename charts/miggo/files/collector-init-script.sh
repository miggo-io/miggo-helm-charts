#!/bin/bash

####################################################################################################
# Collector Initialization Script
#
# This script automates the initialization and configuration process for the miggo-collector pod,
# designed to run as an entrypoint in a Kubernetes environment (typically deployed via Helm).
#
# High-Level Steps and Purpose:
#
# 1. **Environment Validation:** Ensures that all critical environment variables and preconditions
#    are present and set correctly. These variables are typically injected via Kubernetes manifests
#    or Helm charts at deploy time.
#
# 2. **Reading Access Key:** Securely reads the access key from a mounted file or secret, used for
#    authenticating against the miggo authentication service.
#
# 3. **OAuth2 Authentication:** Exchanges the client id + access key for a token via the OAuth2
#    client-credentials flow against the auth service. A successful exchange is the fail-fast check
#    that the credentials are valid and the auth backend is reachable.
#
# 4. **Tenant Information Extraction:** Decodes the OAuth2 token payload and extracts the tenant
#    and project identifiers, logging them. Aborts startup if either is missing or invalid.
#
# 5. **Configuration Generation:** Renders the collector configuration template to its final path
#    (no tenant/project substitution is required).
#
# The script is tolerant to errors: it logs and aborts on failure for every critical step
# to ensure that the collector never starts with invalid configuration or in an unhealthy
# state. On each pod start, performs bootstrapping and configuration generation.
#
# Typical invocation: automatically, as the shell entrypoint of the collector container.
####################################################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"
readonly MAX_RETRIES="${MAX_RETRIES:-3}"
readonly RETRY_DELAY="${RETRY_DELAY:-5}"
readonly TIMEOUT="${TIMEOUT:-30}"

# Logging functions
log() {
    local level="$1"
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] [$SCRIPT_NAME] $*" >&2
}

log_error() { log "ERROR" "$@"; }
log_info() {
    [[ "${LOG_LEVEL}" == "INFO" || "${LOG_LEVEL}" == "DEBUG" ]] && log "INFO " "$@" || true
}
log_debug() {
    [[ "${LOG_LEVEL}" == "DEBUG" ]] && log "DEBUG" "$@" || true
}

# Error handling
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed with exit code $exit_code"
    fi
    return $exit_code
}

trap cleanup EXIT

# Validation functions
validate_environment() {
    log_info "Validating environment variables and paths"

    local required_vars=(
        "CLIENT_ID"
        "ACCESS_KEY_MOUNT_LOCATION"
        "CONFIG_TEMPLATE_PATH"
        "CONFIG_OUTPUT_PATH"
        "AUTH_BASE_URL"
    )

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            log_error "Required environment variable $var is not set"
            return 1
        fi
    done

    if [[ ! -f "${ACCESS_KEY_MOUNT_LOCATION}" ]]; then
        log_error "Access key file not found at: ${ACCESS_KEY_MOUNT_LOCATION}"
        return 1
    fi

    if [[ ! -f "${CONFIG_TEMPLATE_PATH}" ]]; then
        log_error "Config template not found at: ${CONFIG_TEMPLATE_PATH}"
        return 1
    fi

    log_info "Environment validation completed successfully"
    return 0
}

read_access_key() {
    log_info "Reading access key from: ${ACCESS_KEY_MOUNT_LOCATION}"

    local access_key
    if ! access_key="$(cat "${ACCESS_KEY_MOUNT_LOCATION}" 2>/dev/null)"; then
        log_error "Failed to read access key file"
        return 1
    fi

    if [[ -z "${access_key// }" ]]; then
        log_error "Access key is empty or contains only whitespace"
        return 1
    fi

    # Remove any trailing whitespace/newlines
    access_key="$(echo "$access_key" | tr -d '\n\r' | xargs)"

    log_info "Access key read successfully"
    echo "$access_key"
}

decode_jwt_payload() {
    local jwt="$1"

    log_debug "Decoding JWT payload"

    if [[ -z "$jwt" || "$jwt" == "null" ]]; then
        log_error "JWT is empty or null"
        return 1
    fi

    # Extract payload (second part after splitting by '.')
    local payload
    payload=$(echo "$jwt" | cut -d. -f2)

    if [[ -z "$payload" ]]; then
        log_error "Failed to extract JWT payload"
        return 1
    fi

    # Add base64 padding if needed
    local padding=$((4 - ${#payload} % 4))
    if [[ $padding -ne 4 ]]; then
        payload="${payload}$(printf '=%.0s' $(seq 1 $padding))"
    fi

    # Decode base64 and validate JSON
    local decoded
    if decoded=$(echo "$payload" | base64 -d 2>/dev/null); then
        if echo "$decoded" | jq empty 2>/dev/null; then
            log_debug "JWT payload decoded successfully"
            echo "$decoded"
            return 0
        else
            log_error "Decoded JWT payload is not valid JSON"
        fi
    else
        log_error "Failed to decode JWT payload from base64"
    fi

    return 1
}

extract_tenant_info() {
    local jwt_payload="$1"

    log_info "Extracting tenant information from token payload"

    # Claim names match the gateway's JWT mapping: tenant = "dct", project = "project_id".
    local project_id
    project_id=$(echo "$jwt_payload" | jq -r '.project_id // empty')
    if [[ -z "$project_id" || "$project_id" == "null" ]]; then
        log_error "Failed to extract project_id from token payload"
        return 1
    fi

    local tenant_id
    tenant_id=$(echo "$jwt_payload" | jq -r '.dct // empty')
    if [[ -z "$tenant_id" || "$tenant_id" == "null" ]]; then
        log_error "Failed to extract tenant id (dct) from token payload"
        return 1
    fi

    log_info "Project ID: $project_id"
    log_info "Tenant ID: $tenant_id"

    return 0
}

generate_config() {
    log_info "Generating configuration file"
    log_info "Template: ${CONFIG_TEMPLATE_PATH}"
    log_info "Output: ${CONFIG_OUTPUT_PATH}"

    # Create temporary file for safer operation
    local temp_file
    temp_file=$(mktemp) || {
        log_error "Failed to create temporary file"
        return 1
    }

    # Generate config with error handling
    if envsubst < "${CONFIG_TEMPLATE_PATH}" > "$temp_file"; then
        # Validate generated config is not empty
        if [[ -s "$temp_file" ]]; then
            # Move to final location
            if mv "$temp_file" "${CONFIG_OUTPUT_PATH}"; then
                log_info "Configuration file generated successfully"
                return 0
            else
                log_error "Failed to move generated config to final location"
            fi
        else
            log_error "Generated configuration file is empty"
        fi
    else
        log_error "Failed to process configuration template"
    fi

    # Cleanup on failure
    rm -f "$temp_file"
    return 1
}

oauth2_get_token() {
    local client_id="$1"
    local client_secret="$2"
    local token_url="$3"
    local attempt=1

    while [[ $attempt -le $MAX_RETRIES ]]; do
        log_info "Requesting authentication token attempt $attempt of $MAX_RETRIES"

        local response
        local http_code

        if response=$(curl -s -w "\n%{http_code}" \
            --max-time "$TIMEOUT" \
            --retry 0 \
            -X POST "$token_url" \
            -u "${client_id}:${client_secret}" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "grant_type=client_credentials" 2>/dev/null); then

            http_code=$(echo "$response" | tail -n1)
            response=$(echo "$response" | head -n -1)

            log_debug "HTTP response code: $http_code"
            log_debug "Response body: $response"

            if [[ "$http_code" -eq 200 ]]; then
                if echo "$response" | jq empty 2>/dev/null; then
                    local access_token
                    access_token=$(echo "$response" | jq -r '.access_token // empty')

                    if [[ -n "$access_token" && "$access_token" != "null" ]]; then
                        log_info "Authentication token obtained successfully"
                        echo "$access_token"
                        return 0
                    else
                        log_error "Authentication response missing access token"
                    fi
                else
                    log_error "Invalid authentication response received"
                fi
            else
                log_error "Authentication failed with HTTP code: $http_code"
            fi
        else
            log_error "Authentication request failed (network/timeout error)"
        fi

        log_info "Retrying in ${RETRY_DELAY} seconds..."
        sleep "$RETRY_DELAY"

        ((attempt++))
    done

    log_error "Authentication failed after $MAX_RETRIES attempts"
    return 1
}

main() {
    log_info "Starting collector initialization"

    # Set configuration from Helm values (these would be set by the container)
    readonly CLIENT_ID="${CLIENT_ID:-}"
    readonly ACCESS_KEY_MOUNT_LOCATION="${ACCESS_KEY_MOUNT_LOCATION:-/var/secrets/access-key}"
    readonly CONFIG_TEMPLATE_PATH="${CONFIG_TEMPLATE_PATH:-/etc/collector-cm/config-template.yaml}"
    readonly CONFIG_OUTPUT_PATH="${CONFIG_OUTPUT_PATH:-/etc/collector/config.yaml}"
    readonly AUTH_BASE_URL="${AUTH_BASE_URL:-https://auth.miggo.io}"

    # Validate environment
    validate_environment || {
        log_error "Environment validation failed"
        return 1
    }

    # Read access key
    local access_key
    access_key=$(read_access_key) || {
        log_error "Failed to read access key"
        return 1
    }

    # Authenticate via OAuth2 (client credentials). Obtaining a token is the
    # fail-fast check that the access key is valid and the auth backend reachable.
    local access_token
    local token_url="${AUTH_BASE_URL}/oauth2/v1/token"
    access_token=$(oauth2_get_token "$CLIENT_ID" "$access_key" "$token_url") || {
        log_error "Failed to authenticate against ${token_url}"
        return 1
    }

    # Decode the token and extract tenant/project; abort if either is missing
    # or invalid.
    local jwt_payload
    jwt_payload=$(decode_jwt_payload "$access_token") || {
        log_error "Failed to decode token payload"
        return 1
    }

    extract_tenant_info "$jwt_payload" || {
        log_error "Failed to extract tenant information"
        return 1
    }

    # Generate configuration file
    generate_config || {
        log_error "Failed to generate configuration file"
        return 1
    }

    log_info "Collector initialization completed successfully"
    return 0
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
