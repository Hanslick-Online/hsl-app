/*
##################################################################
get container holding images urls as child elements
get container for osd viewer
get container wrapper of osd viewer
##################################################################
*/
var container = document.getElementById("container_facs_2");
container.style.display = "none";

// container height base on screen height
var height = screen.height;
// container for osd viewer
var container = document.getElementById("container_facs_1");
// wrapper of images
var wrapper = document.getElementsByClassName("facsimiles")[0];

/*
##################################################################
check if osd viewer is visible or not
if true get width from sibling container
if false get with from sibling container divided by half
height is always the screen height minus some offset
##################################################################
*/
if (!wrapper.classList.contains("fade")) {
    container.style.height = `${String(height - 400)}px`;
    // set osd wrapper container width
    var container = document.getElementById("section-1");
    if (container !== null) {
        var width = container.clientWidth;
    }
    var container = document.getElementById("viewer-1");
    container.style.width = `${String(width - 50)}px`;
} else {
    container.style.height = `${String(height - 400)}px`;
    // set osd wrapper container width
    var container = document.getElementById("section-1");
    if (container !== null) {
        var width = container.clientWidth;
    }
    var container = document.getElementById("viewer-1");
    container.style.width = `${String(width / 2)}px`;
}

/*
##################################################################
get all image urls stored in span el class tei-xml-images
creates an arrow for for osd viewer with static images
##################################################################
*/
var tileSources = [];
var img = document.getElementsByClassName("tei-xml-images");
for (let i of img) {
    var image = i.getAttribute("dta-src");
    var imageURL = {type: 'image', url: image};
    tileSources.push(imageURL);
}

/*
##################################################################
initialize osd
##################################################################
*/
var viewer = OpenSeadragon({
    id: 'container_facs_1',
    prefixUrl: 'https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/',
    sequenceMode: true,
    showNavigator: true,
    imageLoaderLimit: 20,
    tileSources: tileSources
});
/*
##################################################################
remove container holding the images url
##################################################################
*/
setTimeout(function() {
    document.getElementById("container_facs_2").remove();
}, 500);


/*
##################################################################
triggers on scroll and switches osd viewer image base on 
viewport position of next and previous element with class pb
pb = pagebreaks
##################################################################
*/
var element = document.getElementsByClassName('pb');
var idx = 0;
var prev_idx = -1;
var position = document.documentElement.scrollTop;

window.addEventListener("scroll", function(event) {
    // elements in view
    var esiv = [];
    for (let el of element) {
        if (isInViewportAll(el)) {
            esiv.push(el);
        }
    }
    if (esiv.length != 0) {
        // first element in view
        var eiv = esiv[0];
        var source = esiv[0].getAttribute("source");
        // get idx of eiv
        var eiv_idx = Array.from(element).findIndex((el) => el === eiv);
    
        // get scrolltop after scrolling
        var scroll = document.documentElement.scrollTop;
        if (scroll > position) {
            if (isInViewport(element[eiv_idx])) {
                if (eiv_idx == 0) {
                    // do not trigger on first image
                } else {
                    var src = element[eiv_idx - 1].getAttribute("source");
                    var current0 = viewer.world.getItemAt(0);
                    var current1 = current0.source.url;
                    var current2 = current0.source.url.split("/");
                    var current3 = current2[current2.length - 5].replace(".jp2", "");
                    // console.log("src", src);
                    // console.log("current", current3);
                    if (src == current3) {
                        viewer.goToNextPage();
                        idx += 1;
                        prev_idx += 1;
                    }
                }
            }
        } else {
            if (isInViewport(element[eiv_idx])) {
                if (eiv_idx == 0) {
                    // do not trigger on first image
                } else {
                    var src = element[eiv_idx].getAttribute("source");
                    var current0 = viewer.world.getItemAt(0);
                    var current1 = current0.source.url;
                    var current2 = current0.source.url.split("/");
                    var current3 = current2[current2.length - 5].replace(".jp2", "");
                    // console.log("src back", src);
                    // console.log("current back", current3);
                    if (src == current3) {
                        viewer.goToPreviousPage();
                        idx -= 1;
                        prev_idx -= 1;
                    } 
                }
            } 
        }
        position = document.documentElement.scrollTop;
    }
});



// window.addEventListener("scroll", function(event) {
//     var scroll = document.documentElement.scrollTop;
//     // console.log("Position");
//     // console.log(position);
//     // console.log("Scroll");
//     // console.log(scroll);
//     // console.log("El offsettop");
//     // console.log(element[idx].offsetTop);
//     if (scroll > position) {
//         if (isInViewport(element[idx])) {
//             if (idx == 0) {
//                 idx += 1;
//                 prev_idx += 1;
//             } else {
//                 var source = element[idx - 1].getAttribute("source");
//                 var current0 = viewer.world.getItemAt(0);
//                 var current1 = current0.source.url;
//                 var current2 = current0.source.url.split("/");
//                 var current3 = current2[current2.length - 5].replace(".jp2", "");
//                 if (source === current3) {
//                     viewer.goToNextPage();
//                     idx += 1;
//                     prev_idx += 1;
//                 } else {
//                     var current = current1.replace(current3, source);
//                     viewer.world.getItemAt(0).source.url = current;
//                 }
//             }
//         }
//     } else {
//         if (prev_idx >= 0 && isInViewport(element[prev_idx])) {
//             if (prev_idx == 0) {
//                 idx -= 1;
//                 prev_idx -= 1;
//             } else {
//                 var source = element[idx - 1].getAttribute("source");
//                 var current0 = viewer.world.getItemAt(0);
//                 var current1 = current0.source.url;
//                 var current2 = current0.source.url.split("/");
//                 var current3 = current2[current2.length - 5].replace(".jp2", "");
//                 if (source === current3) {
//                     viewer.goToPreviousPage();
//                     idx -= 1;
//                     prev_idx -= 1;
//                 } else {
//                     var current = current1.replace(current3, source);
//                     viewer.world.getItemAt(0).source.url = current;
//                 }
//             }
//         } 
//     }
//     position = document.documentElement.scrollTop;
// }, false);

/*
##################################################################
accesses osd viewer prev and next button to switch image and
scrolls to next or prev span element with class pb (pagebreak)
##################################################################
*/
var element_a = document.getElementsByClassName('anchor-pb');
var prev = document.querySelector("div[title='Previous page']");
var next = document.querySelector("div[title='Next page']");
prev.addEventListener("click", () => {
    if (idx == 0) {
        element_a[idx].scrollIntoView();
    } else {
        element_a[prev_idx].scrollIntoView();
        idx -= 1;
        prev_idx -= 1;
    }
});
next.addEventListener("click", () => {
    if (idx == 0) {
        idx += 1;
        prev_idx += 1;
        element_a[idx].scrollIntoView();
    } else {
        idx += 1;
        prev_idx += 1;
        element_a[idx].scrollIntoView();
    }
});

/*
##################################################################
function to check if element is close to top of window viewport
##################################################################
*/
function isInViewport(element) {
    // Get the bounding client rectangle position in the viewport
    var bounding = element.getBoundingClientRect();
    // Checking part. Here the code checks if el is close to top of viewport.
    // console.log("Top");
    // console.log(bounding.top);
    // console.log("Bottom");
    // console.log(bounding.bottom);
    if (
        bounding.top <= 180 &&
        bounding.bottom <= 210 &&
        bounding.top >= 0 &&
        bounding.bottom >= 0
        // bounding.top >= 0 &&
        // bounding.left >= 0 &&
        // bounding.right <= (window.innerWidth || document.documentElement.clientWidth) &&
        // bounding.bottom <= (window.innerHeight || document.documentElement.clientHeight)
    ) {
        return true;
    } else {
        return false;
    }
}

function isInViewportAll(element) {
    // Get the bounding client rectangle position in the viewport
    var bounding = element.getBoundingClientRect();
    // Checking part. Here the code checks if el is close to top of viewport.
    // console.log("Top");
    // console.log(bounding.top);
    // console.log("Bottom");
    // console.log(bounding.bottom);
    if (
        bounding.top >= 0 &&
        bounding.left >= 0 &&
        bounding.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        bounding.right <= (window.innerWidth || document.documentElement.clientWidth)
    ) {
        return true;
    } else {
        return false;
    }
}