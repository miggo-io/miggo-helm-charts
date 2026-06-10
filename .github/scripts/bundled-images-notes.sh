#!/usr/bin/env bash
# Render the chart and print a marker-wrapped markdown section listing every
# container image the chart can deploy and its tag. Pure: no GitHub/network use,
# so it can be run locally against any chart checkout.
#
# Usage: bundled-images-notes.sh [chart-dir]   (chart-dir defaults to charts/miggo)
set -euo pipefail

chart_dir="${1:-charts/miggo}"

# Force-enable every component so default-disabled images render too. A new
# default-disabled component must be added here with its own --set <c>.enabled=true.
rendered=$(helm template "$chart_dir" \
  --set miggoRuntime.enabled=true \
  --set miggoRuntime.profiler.enabled=true \
  --set miggoRuntime.fluentbit.enabled=true)

images=$(echo "$rendered" | grep -oE 'image: "?[^"]+"?' | sed -E 's/^image: //; s/"//g' | sort -u)

version=$(grep -E '^version:' "$chart_dir/Chart.yaml" | head -1 | sed -E 's/version:[[:space:]]*//; s/"//g')

rows=""
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  tag="${ref##*:}"        # after the last ':'
  image="${ref%:*}"       # before the last ':'
  component="${image##*/}" # repository basename
  rows+="| ${component} | \`${image}\` | \`${tag}\` |"$'\n'
done <<< "$images"

cat <<EOF
<!-- BUNDLED_IMAGES_START -->
## 📦 Bundled images

| Component | Image | Tag |
|---|---|---|
${rows}
<sub>All images the chart can deploy, rendered from chart \`${version}\`. Whether each runs depends on your values.</sub>
<!-- BUNDLED_IMAGES_END -->
EOF
