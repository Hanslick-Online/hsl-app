function compare(){
    let v1 = document.getElementById("selectV1").value,
        v2 = document.getElementById("selectV2").value;
        
    let one = document.getElementById(v1).textContent.replace(/\s+/g, ' '),
    other = document.getElementById(v2).textContent.replace(/\s+/g, ' '),
    color = '';
    
    let span = null;
                        
    let diffLevel = document.getElementById("diffLevel").value;
    const diff = diffLevel === "sentences" ? Diff.diffSentences(one, other) :  
                 /*diffLevel === "lines" ? Diff.diffLines(one, other) :*/  
                 Diff.diffWords(one, other),
    display = document.getElementById('display'),
    fragment = document.createDocumentFragment();
    
    diff.forEach((part) => {
    // green for additions, red for deletions
    // grey for common parts
    const diffClass = part.added ? 'diff-added' :
    part.removed ? 'diff-removed' : 'diff-unchanged';
    span = document.createElement('span');
    span.classList.add(diffClass) ;
    span.appendChild(document
    .createTextNode(part.value));
    fragment.appendChild(span);
    });
    display.innerHTML = '';
    display.appendChild(fragment);
};

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
            const list = document.createElement('ul');
            list.style.listStyleType = 'none';
            list.style.paddingLeft = '0';
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
};

document.addEventListener('DOMContentLoaded', loadFootnotes);