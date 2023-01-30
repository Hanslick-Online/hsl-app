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