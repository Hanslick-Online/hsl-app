function getCompCellText(cellId){
    const el = document.getElementById(cellId);
    if(!el){
        return { body: '', notes: '' };
    }

    const body = (el.dataset && el.dataset.compBodyText)
        ? el.dataset.compBodyText
        : el.textContent;

    const notes = Array.from(el.querySelectorAll('.comp-footnotes-container .footnotes li'))
        .map((li) => {
            const num = li.querySelector('.footnote_link')?.textContent?.trim() || '';
            const txt = li.querySelector('.footnote_text')?.textContent?.trim() || '';
            if(!num && !txt){
                return '';
            }
            return num ? `${num} ${txt}` : txt;
        })
        .filter(Boolean)
        .join(' ');

    return {
        body: body.replace(/\s+/g, ' ').trim(),
        notes: notes.replace(/\s+/g, ' ').trim()
    };
}

function cacheCompBodyTexts(){
    const cells = document.querySelectorAll('tr.data > td[id]');
    cells.forEach((td) => {
        if(!td.dataset.compBodyText){
            td.dataset.compBodyText = td.textContent.replace(/\s+/g, ' ').trim();
        }
    });
}

function buildDiffFragment(one, other, diffLevel){
    const diff = diffLevel === 'sentences'
        ? Diff.diffSentences(one, other)
        : Diff.diffWords(one, other);

    const fragment = document.createDocumentFragment();
    diff.forEach((part) => {
        const diffClass = part.added ? 'diff-added' :
            part.removed ? 'diff-removed' : 'diff-unchanged';
        const span = document.createElement('span');
        span.classList.add(diffClass);
        span.appendChild(document.createTextNode(part.value));
        fragment.appendChild(span);
    });
    return fragment;
}

function renderDiffSection(title, one, other, diffLevel){
    const section = document.createElement('div');
    section.className = 'comp-result-section mb-3';

    const heading = document.createElement('h6');
    heading.className = 'mb-2';
    heading.textContent = title;
    section.appendChild(heading);

    const body = document.createElement('div');
    body.className = 'comp-result-body';
    body.appendChild(buildDiffFragment(one, other, diffLevel));
    section.appendChild(body);

    return section;
}

function getDisplayContainer(){
    const display = document.getElementById('display');
    if(!display){
        return null;
    }

    // Older generated pages use <p id="display">; replace it to allow block sections.
    if(display.tagName === 'P'){
        const replacement = document.createElement('div');
        replacement.id = 'display';
        display.replaceWith(replacement);
        return replacement;
    }

    return display;
}

function compare(){
    const v1 = document.getElementById('selectV1').value;
    const v2 = document.getElementById('selectV2').value;

    const one = getCompCellText(v1);
    const other = getCompCellText(v2);

    const diffLevel = document.getElementById('diffLevel').value;
    const display = getDisplayContainer();
    if(!display){
        return;
    }

    display.innerHTML = '';

    display.appendChild(renderDiffSection('Textvergleich (Haupttext)', one.body, other.body, diffLevel));
    display.appendChild(renderDiffSection('Textvergleich (Fußnoten)', one.notes, other.notes, diffLevel));
};

async function fetchFootnotesForLink(link){
    const parsed = new URL(link.getAttribute('href'), window.location.href);
    const targetId = parsed.hash ? parsed.hash.slice(1) : '';
    if(!targetId){
        return null;
    }

    const editionLabel = link.textContent.trim();
    const pageUrl = parsed.href.split('#')[0];

    const res = await fetch(pageUrl);
    if(!res.ok){
        return null;
    }
    const html = await res.text();
    const doc = new DOMParser().parseFromString(html, 'text/html');
    const para = doc.getElementById(targetId);
    if(!para){
        return null;
    }

    const notes = [];
    const seenTargets = new Set();
    const links = Array.from(para.querySelectorAll('a[href^="#"]'));
    for(const a of links){
        const target = a.getAttribute('href').slice(1);
        if(!target || seenTargets.has(target)){
            continue;
        }
        seenTargets.add(target);

        const anchor = doc.getElementById(target);
        const li = anchor ? anchor.closest('li') : null;
        if(!li){
            continue;
        }
        const body = li.querySelector('.footnote_text');
        if(!body){
            continue;
        }
        const number = a.textContent.trim() || target;
        const content = body.innerHTML.trim();
        notes.push({ number, content });
    }

    if(!notes.length){
        return null;
    }

    return { editionLabel, notes };
}

function renderFootnotesBlock(notes){
    const block = document.createElement('div');
    block.className = 'comp-footnote-block mt-3';

    const heading = document.createElement('div');
    heading.className = 'fw-semibold';
    heading.textContent = 'Fußnoten';

    const list = document.createElement('ul');
    list.className = 'footnotes';

    notes.forEach((note) => {
        const li = document.createElement('li');

        const linkSpan = document.createElement('span');
        linkSpan.className = 'footnote_link';
        linkSpan.textContent = note.number;

        const textSpan = document.createElement('span');
        textSpan.className = 'footnote_text';
        textSpan.innerHTML = note.content;

        li.appendChild(linkSpan);
        li.appendChild(textSpan);
        list.appendChild(li);
    });

    block.appendChild(heading);
    block.appendChild(list);
    return block;
}

// Load footnotes for each edition referenced in the header and render them inside the corresponding column.
async function loadFootnotes(){
    const table = document.querySelector('.table');
    if(!table){
        return;
    }

    cacheCompBodyTexts();

    // Remove previously injected footnotes
    table.querySelectorAll('.comp-footnotes-container').forEach((el) => el.remove());

    const headerCells = Array.from(table.querySelectorAll('tr.label > th'));
    const dataCells = Array.from(table.querySelectorAll('tr.data > td'));
    if(!headerCells.length || !dataCells.length){
        return;
    }

    await Promise.all(headerCells.map(async (headerCell, colIndex) => {
        const td = dataCells[colIndex];
        if(!td){
            return;
        }

        const refs = Array.from(headerCell.querySelectorAll('.link_ref'));
        if(!refs.length){
            return;
        }

        const results = await Promise.all(refs.map(async (link) => {
            try{
                return await fetchFootnotesForLink(link);
            } catch(err){
                return null;
            }
        }));

        const mergedNotes = [];
        const seenNumbers = new Set();
        const seenNoNumber = new Set();

        results.filter(Boolean).forEach((entry) => {
            entry.notes.forEach((note) => {
                const number = (note.number || '').trim();
                const content = (note.content || '').trim();
                if(!number && !content){
                    return;
                }

                if(number){
                    if(seenNumbers.has(number)){
                        return;
                    }
                    seenNumbers.add(number);
                    mergedNotes.push({ number, content });
                    return;
                }

                const normalizedContent = content.replace(/\s+/g, ' ');
                if(seenNoNumber.has(normalizedContent)){
                    return;
                }
                seenNoNumber.add(normalizedContent);
                mergedNotes.push({ number, content });
            });
        });

        if(!mergedNotes.length){
            return;
        }

        const container = document.createElement('div');
        container.className = 'comp-footnotes-container';

        const hr = document.createElement('hr');
        container.appendChild(hr);

        container.appendChild(renderFootnotesBlock(mergedNotes));

        td.appendChild(container);
    }));
};

document.addEventListener('DOMContentLoaded', loadFootnotes);
