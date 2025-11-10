# How to Use BibTeX Citations in FASTR Documentation

## Quick Start

### 1. Add References to `references.bib`

Open `references.bib` and add your references in BibTeX format:

```bibtex
@article{smith2020,
  author = {Smith, John and Doe, Jane},
  title = {Data Quality in Health Systems},
  journal = {Journal of Health Informatics},
  year = {2020},
  volume = {15},
  number = {3},
  pages = {123--145}
}
```

### 2. Cite in Your Markdown Files

In any `.md` file, use `[@citation_key]` to cite:

```markdown
Studies have shown data quality issues [@smith2020].

Multiple citations can be used [@smith2020; @jones2019].
```

### 3. Add Bibliography Section

At the end of each document where you want references to appear, add:

```markdown
## References

\bibliography
```

The `\bibliography` command will automatically generate the formatted reference list for all citations used in that page.

## Citation Styles

Current setup uses **APA style**. To change to a different style, edit `mkdocs.yml`:

```yaml
  - bibtex:
      bib_file: "references.bib"
      csl_file: "https://raw.githubusercontent.com/citation-style-language/styles/master/[STYLE].csl"
```

Available styles:
- `apa.csl` - APA (American Psychological Association)
- `chicago-author-date.csl` - Chicago
- `vancouver.csl` - Vancouver (common in medical journals)
- `harvard-cite-them-right.csl` - Harvard
- `ieee.csl` - IEEE

Full list: https://github.com/citation-style-language/styles

## BibTeX Entry Types

Common entry types:

### Journal Article
```bibtex
@article{key2020,
  author = {Last, First and Last2, First2},
  title = {Article Title},
  journal = {Journal Name},
  year = {2020},
  volume = {10},
  number = {2},
  pages = {123--145},
  doi = {10.1234/example}
}
```

### Book
```bibtex
@book{key2019,
  author = {Author Name},
  title = {Book Title},
  publisher = {Publisher Name},
  year = {2019},
  address = {City}
}
```

### Technical Report
```bibtex
@techreport{who2023,
  author = {{World Health Organization}},
  title = {Report Title},
  institution = {WHO},
  year = {2023},
  type = {Technical Report}
}
```

### Conference Paper
```bibtex
@inproceedings{key2021,
  author = {Author Name},
  title = {Paper Title},
  booktitle = {Conference Name},
  year = {2021},
  pages = {100--110}
}
```

### Website/Online Resource
```bibtex
@misc{key2022,
  author = {Author Name},
  title = {Web Page Title},
  year = {2022},
  url = {https://example.com},
  note = {Accessed: 2024-01-15}
}
```

## Example Usage in Documentation

```markdown
# Module 1: Data Quality Assessment

Health-facility data collected through HMIS are critical for health sector
performance assessment [@smith2020; @jones2019]. However, studies in
Sub-Saharan Africa have reported challenges with data quality [@who2023].

Recent improvements have been made through systematic assessment and
improvement approaches [@brown2021].

## References

\bibliography
```

This will automatically generate:

> **References**
>
> Brown, A. et al. (2021). Systematic approaches to data quality...
>
> Jones, K. (2019). Health management information systems...
>
> Smith, J. & Doe, J. (2020). Data quality in health systems...
>
> World Health Organization. (2023). Report Title...

## Tips

1. **Unique Keys**: Each reference must have a unique citation key (e.g., `smith2020`)
2. **Author Format**: Use `and` to separate multiple authors
3. **Organizations**: Wrap organization names in double braces: `{{WHO}}`
4. **Page Ranges**: Use double dashes for page ranges: `123--145`
5. **Special Characters**: Protect capitalization with braces: `{HMIS}` or `{Sub-Saharan Africa}`

## Testing

After adding references, test with:

```bash
python3 -m mkdocs build
```

If there are errors, check:
- BibTeX syntax in `references.bib`
- Citation keys match between `.bib` file and markdown
- `\bibliography` is included where you want references to appear
