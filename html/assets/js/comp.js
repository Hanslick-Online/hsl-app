function getCompCellText(cellId){
    const el = document.getElementById(cellId);
    if(!el){
        return '';
    }
    const raw = (el.dataset && el.dataset.compBodyText)
        ? el.dataset.compBodyText
        : el.textContent;
    return raw.replace(/\s+/g, ' ');
}

function cacheCompBodyTexts(){
    const cells = document.querySelectorAll('tr.data > td[id]');
    cells.forEach((td) => {
        if(!td.dataset.compBodyText){
            td.dataset.compBodyText = td.textContent.replace(/\s+/g, ' ').trim();
        }
    });
}

function compare(){
    const v1 = document.getElementById('selectV1').value;
    const v2 = document.getElementById('selectV2').value;

    const one = getCompCellText(v1);
    const other = getCompCellText(v2);

    let span = null;

    const diffLevel = document.getElementById('diffLevel').value;
    const diff = diffLevel === 'sentences'
        ? Diff.diffSentences(one, other)
        : Diff.diffWords(one, other);
    const display = document.getElementById('display');
    const fragment = document.createDocumentFragment();

    diff.forEach((part) => {
        const diffClass = part.added ? 'diff-added' :
            part.removed ? 'diff-removed' : 'diff-unchanged';
        span = document.createElement('span');
        span.classList.add(diffClass);
        span.appendChild(document.createTextNode(part.value));
        fragment.appendChild(span);
    });
    display.innerHTML = '';
    display.appendChild(fragment);
};

<<<<<<< HEAD
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

function renderFootnotesBlock(editionLabel, notes){
    const block = document.createElement('div');
    block.className = 'comp-footnote-block mt-3';

    const heading = document.createElement('div');
    heading.className = 'fw-semibold';
    heading.textContent = `Fußnoten ${editionLabel}`;

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

        const footnoteBlocks = results.filter(Boolean);
        if(!footnoteBlocks.length){
            return;
        }

        const container = document.createElement('div');
        container.className = 'comp-footnotes-container';

        const hr = document.createElement('hr');
        container.appendChild(hr);

        footnoteBlocks.forEach(({ editionLabel, notes }) => {
            container.appendChild(renderFootnotesBlock(editionLabel, notes));
        });

        td.appendChild(container);
    }));
=======
// Load footnotes for each edition referenced in the header and render them below the table.
async function loadFootnotes(){
    const table = document.querySelector('.table');
    const cardBody = document.querySelector('.card-body');
    if(!table || !cardBody){
        return;
    }

    let container = document.getElementById('comp-footnotes');
    if(!container){
        container = document.createElement('div');
        container.id = 'comp-footnotes';
        container.className = 'mt-3';
        cardBody.appendChild(container);
    } else {
        container.innerHTML = '';
    }

    const linkRefs = Array.from(table.querySelectorAll('.link_ref'));
    if(!linkRefs.length){
        return;
    }

    const blocks = await Promise.all(linkRefs.map(async (link) => {
        const parsed = new URL(link.getAttribute('href'), window.location.href);
        const targetId = parsed.hash ? parsed.hash.slice(1) : '';
        if(!targetId){
            return null;
        }

        const editionLabel = link.textContent.trim();
        const pageUrl = parsed.href.split('#')[0];

        try{
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

            const footnoteLinks = Array.from(para.querySelectorAll('a[href^="#"]'));
            if(!footnoteLinks.length){
                return null;
            }

            const notes = [];
            footnoteLinks.forEach((a) => {
                const target = a.getAttribute('href').slice(1);
                if(!target){
                    return;
                }
                const footnoteAnchor = doc.getElementById(target);
                if(!footnoteAnchor){
                    return;
                }
                const li = footnoteAnchor.closest('li') || footnoteAnchor.parentElement;
                if(!li){
                    return;
                }
                const body = li.querySelector('.footnote_text');
                const content = body ? body.innerHTML.trim() : li.innerHTML.trim();
                const number = a.textContent.trim() || target;
                notes.push({ number, content });
            });

            if(!notes.length){
                return null;
            }

            const block = document.createElement('div');
            block.className = 'comp-footnote-block mb-3';
            const heading = document.createElement('h5');
            heading.textContent = `Fußnoten ${editionLabel}`;
            const list = document.createElement('ol');
            notes.forEach((note) => {
                const li = document.createElement('li');
                li.innerHTML = `<strong>${note.number}</strong> ${note.content}`;
                list.appendChild(li);
            });
            block.appendChild(heading);
            block.appendChild(list);
            return block;
        } catch(err){
            return null;
        }
    }));

    blocks.filter(Boolean).forEach((block) => container.appendChild(block));
>>>>>>> 210d41b (Add footnotes to collation)
};

document.addEventListener('DOMContentLoaded', loadFootnotes);