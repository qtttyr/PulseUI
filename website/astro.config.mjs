// @ts-check
import { defineConfig } from "astro/config";
import { fileURLToPath } from "node:url";

// Allow importing real Swift sources from the repo root (Sources/PulseUI) ?raw.
const repoRoot = fileURLToPath(new URL("../../", import.meta.url));

export default defineConfig({
  site: "https://pulse-ui.dev",
  compressHTML: true,
  build: {
    inlineStylesheets: "always",
  },
  vite: {
    server: {
      fs: {
        allow: [repoRoot],
      },
    },
    build: {
      assetsInlineLimit: 0,
    },
    optimizeDeps: {
      include: [],
    },
  },
});