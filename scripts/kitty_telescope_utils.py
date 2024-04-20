import sys
import bibtexparser


def parse_bibtex_file(bibtex_file_path):
    with open(bibtex_file_path) as bibtex_file:
        bibtex_str = bibtex_file.read()

    bib_database = bibtexparser.loads(bibtex_str)
    return bib_database.entries


def format_for_fzf(bib_entries):
    titles = []
    details = {}
    for entry in bib_entries:
        title = entry.get('title', 'No Title')
        detail_str = '\n'.join(f"{key}: {entry[key]}" for key in entry)
        titles.append(title)
        details[title] = detail_str
    return titles, details


def main():
    if sys.argv[1] == "--fzf-bib":
        if len(sys.argv) != 3:
            print("Usage: python script.py --fzf-bib <path_to_bibtex_file>")
            sys.exit(1)
        bibtex_file_path = sys.argv[2]
        bib_entries = parse_bibtex_file(bibtex_file_path)
        titles, details = format_for_fzf(bib_entries)
        # Save detailed entries to a temporary file for `fzf` preview
        with open('/tmp/bibtex_details.txt', 'w') as detail_file:
            for title, detail in details.items():
                detail_file.write(f"==={title}===\n{detail}\n\n")
        # Print titles for `fzf` selection
        for title in titles:
            print(title)


if __name__ == "__main__":
    main()


