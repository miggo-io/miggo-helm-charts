# Helm Releaser Action

## Overview

This action provides the same functionality as the official [helm/chart-releaser-action](https://github.com/helm/chart-releaser-action) with additional configuration options to support cross-repository workflows.

## Purpose

This custom implementation was created to address a specific limitation in the official action: the inability to configure the target repository. This enhancement is particularly valuable for us because we need to run chart release workflows from the k8s-integrations repository while targeting this repo.

## When to Use Official Action

We recommend monitoring [helm/chart-releaser-action#194](https://github.com/helm/chart-releaser-action/issues/194) for updates. Once the official action supports repository configuration, we plan to migrate back to the official implementation to ensure we receive the latest features and security updates.

## Usage

Same as official action at this [point in time](https://github.com/helm/chart-releaser/releases/tag/v1.8.1)
