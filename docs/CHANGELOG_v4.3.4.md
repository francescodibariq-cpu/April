# April Fallen v4.3.4

## Search and navigation

- Replaced the content context strip with a centered title-bar search button.
- Added searchable tabs, modules, features, settings, option names, and internal IDs.
- Added keyboard navigation, Tab autocomplete, and Enter-to-open behavior.
- Search selections now navigate to the correct tab, expand collapsed modules, autoscroll, and briefly highlight the destination without changing its value.
- Hidden dependent controls can be revealed temporarily for the search highlight without enabling their parent feature.

## Cleanup

- Extracted the search palette into its own UI module.
- Reused the normal text-field renderer for search instead of introducing a second input implementation.
- Removed the legacy overlay-theme dependency from tooltip rendering.
- Completed the standalone UI bundle's missing dependency list.
