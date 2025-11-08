# FASTR Methodology Docs

Public documentation for the FASTR methodology, including the background chapter and the four analytical modules. The content is authored in Markdown and published with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).

## Live site

- **Production**: https://FASTR-Analytics.github.io/docs/
- The site is deployed automatically via `mkdocs gh-deploy` to the `gh-pages` branch.

## Working locally

```bash
cd methodology
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt  # or pip install mkdocs mkdocs-material mkdocs-minify-plugin
mkdocs serve
```

Changes are served at http://127.0.0.1:8000/ with hot reload. When you are ready to publish:

```bash
mkdocs build          # optional sanity check
mkdocs gh-deploy --force
```

## Repo layout

- `methodology/mkdocs.yml`: MkDocs configuration.
- `methodology/docs/`: All source Markdown, images, and custom CSS.
- `methodology/site/`: Build artifacts (ignored) created by `mkdocs build`.
- `report_inputs/`: Supporting inputs for the FASTR analysis workflow.

Please open an issue or PR for any corrections so teammates stay aligned with the published methodology.
