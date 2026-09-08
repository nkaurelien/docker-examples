def on_page_markdown(markdown, page, config, files):
    if 'tags' in page.meta:
        raw = page.meta['tags']
        if isinstance(raw, str):
            # Split on comma or space
            tags_list = [t.strip().lstrip(',') for t in raw.replace(',', ' ').split() if t.strip()]
            page.meta['tags'] = tags_list
    return markdown
