VectorCraft mobile UI patch bundle

1. Replace .github/workflows/build-apk.yml in your ms1531/craft repository with the included workflow.
2. Add vectorcraft-mobile-prepare.sh to the repository root.
3. Open GitHub Actions, select Build ArtCraft Android APK, choose vectorcraft and release, then run it.

The patch makes the large Properties/Layers dock collapse automatically on phone-width screens and when rotating into portrait. It does not yet implement triple-tap zoom; pinch zoom and pan rely on the upstream touch support.
