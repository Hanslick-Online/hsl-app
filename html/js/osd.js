/*
##################################################################
get container holding images urls as child elements
get container for osd viewer
get container wrapper of osd viewer
##################################################################
*/
// var container = document.getElementById("container_facs_2");
// container.style.display = "none";

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
var element = document.getElementsByClassName('pb');
var tileSources = [];
var img = element[0].getAttribute("source");
var img = `https://iiif.acdh.oeaw.ac.at/iiif/images/hsl-vms/${img}.jp2/full/max/0/default.jpg`;
var imageURL = {
    type: 'image',
    url: img
};
tileSources.push(imageURL);

/*
##################################################################
initialize osd
##################################################################
*/
var viewer = OpenSeadragon({
    id: 'container_facs_1',
    prefixUrl: 'https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.0.0/images/',
    sequenceMode: true,
    showNavigator: true,
    tileSources: tileSources
});
/*
##################################################################
remove container holding the images url
##################################################################
*/
// setTimeout(function() {
//     document.getElementById("container_facs_2").remove();
// }, 500);


/*
##################################################################
triggers on scroll and switches osd viewer image base on 
viewport position of next and previous element with class pb
pb = pagebreaks
##################################################################
*/
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
        // get idx of element
        var eiv_idx = Array.from(element).findIndex((el) => el === eiv);
        // get scrolltop after scrolling
        var scroll = document.documentElement.scrollTop;
        // depending if the user scrolls up or down other viewport positions are
        // important
        if (scroll > position) {
            // scroll down and change image in osd
            if (isInViewportDown(element[eiv_idx])) {
                loadNewImage(viewer.world.getItemAt(0), element[eiv_idx]);
            }
        } else {
            // scroll up and change image in osd
            if (eiv_idx === 0) {
                // first image in index needs other viewport position
                if (isInViewportDown(element[eiv_idx])) {
                    loadNewImage(viewer.world.getItemAt(0), element[eiv_idx]);           
                }
            } else {
                if (isInViewportUp(element[eiv_idx])) {
                    loadNewImage(viewer.world.getItemAt(0), element[eiv_idx]);
                }
            } 
        }
        // update scroll position to identify if user scrolls up
        position = document.documentElement.scrollTop;
    }
});

// function to trigger image load and remove events
function loadNewImage(old_image, new_item) {
    if (new_item) {
        var new_image = new_item.getAttribute("source");
        if (old_image) {
            var current1 = old_image.source.url;
            var current2 = old_image.source.url.split("/");
            var current3 = current2[current2.length - 5].replace(".jp2", "");
            var new_image = current1.replace(current3, new_image);
            viewer.addSimpleImage({
                url: new_image,
                success: function(event) {
                    viewer.world.removeItem(old_image);
                }
            });
        }
    }
}

/*
##################################################################
accesses osd viewer prev and next button to switch image and
scrolls to next or prev span element with class pb (pagebreak)
##################################################################
*/
var element_a = document.getElementsByClassName('anchor-pb');
var prev = document.querySelector("div[title='Previous page']");
var next = document.querySelector("div[title='Next page']");
prev.style.opacity = 1;
next.style.opacity = 1;
var idx = 0;
var prev_idx = -1;
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
    idx += 1;
    prev_idx += 1;
    element_a[idx].scrollIntoView();
});

/*
##################################################################
function to check if element is close to top of window viewport
##################################################################
*/
function isInViewportDown(element) {
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
    ) {
        return true;
    } else {
        return false;
    }
}

function isInViewportUp(element) {
    // Get the bounding client rectangle position in the viewport
    var bounding = element.getBoundingClientRect();
    // Checking part. Here the code checks if el is close to top of viewport.
    // console.log("Top");
    // console.log(bounding.top);
    // console.log("Bottom");
    // console.log(bounding.bottom);
    if (
        bounding.top <= 300 &&
        bounding.bottom <= 320 &&
        bounding.top >= 250 &&
        bounding.bottom >= 250
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