/*
##################################################################
get container holding images urls as child elements
get container for osd viewer
get container wrapper of osd viewer
##################################################################
*/
// var container = document.getElementById("container_facs_2");
// container.style.display = "none";
var height = screen.height;
var container = document.getElementById("container_facs_1");
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
    var container = document.getElementById("text");
    if (container !== null) {
        var width = container.clientWidth;
    }
    var container = document.getElementById("viewer-1");
    container.style.width = `${String(width - 150)}px`;
} else {
    container.style.height = `${String(height - 400)}px`;
    // set osd wrapper container width
    var container = document.getElementById("text");
    if (container !== null) {
        var width = container.clientWidth;
    }
    var container = document.getElementById("viewer-1");
    container.style.width = `${String(width / 2)}px`;
}

/*
##################################################################
get all image urls stored in span el class tei-xml-images
creates an array for osd viewer with static images
##################################################################
*/
// var element_json = {};
var element = document.getElementsByClassName('anchor-pb');
// for (el in element) {
//     if (element[el].getAttribute) {
//         element_json[el] = element[el].getAttribute("source");
//     }
// };
// sessionStorage.setItem("hsl-images", JSON.stringify(element_json));
var tileSources = [];
var img = element[0].getAttribute("source");
if (img.includes("api.digitale-sammlungen.de")) {
    img = `${img}/full/full/0/default.jpg`;
} else if (img.includes("hsl-nfp")) {
    img = `https://iiif.acdh.oeaw.ac.at/iiif/images/${img}.jp2/full/full/0/default.jpg`;
} else if (img.includes("hsl-vms")) {
    img = `https://iiif.acdh.oeaw.ac.at/iiif/images/${img}.jp2/full/full/0/default.jpg`;
    
} else if (img.includes("hsl-doc")) {
    if (img.endsWith(".jpg")) {
    img = img.slice(0, -4); // removes the last 4 characters (".jpg")
  };
    img = `https://iiif.acdh.oeaw.ac.at/iiif/images/${img}.jp2/full/full/0/default.jpg`;
    
}
else {
    var img = `${img}?format=iiif`;
}
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
    prefixUrl: 'https://cdnjs.cloudflare.com/ajax/libs/openseadragon/5.0.1/images/',
    sequenceMode: true,
    showNavigator: true,
    tileSources: tileSources,
    showFullPageControl: false
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
index and previous index for click navigation in osd viewer
locate index of anchor element
##################################################################
*/
var idx = 0;
var prev_idx = -1;

/*
##################################################################
triggers on scroll and switches osd viewer image base on 
viewport position of next and previous element with class pb
pb = pagebreaks
##################################################################
*/
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
        idx = eiv_idx + 1;
        prev_idx = eiv_idx - 1
        // test if element is in viewport position to load correct image
        if (isInViewport(element[eiv_idx])) {
            loadNewImage(element[eiv_idx]);
        }
    }
});

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
prev.addEventListener("click", () => {
    if (prev_idx = idx) {
        prev_idx = idx - 1;
    }
    if (idx <= 0) {
        element_a[0].scrollIntoView();
    } 
    else {
        element_a[prev_idx].scrollIntoView();
    }
});
next.addEventListener("click", () => {
    if (idx > element_a.length - 1) {
        idx = element_a.length - 1;
        prev_idx = idx -1 ;
    }
    element_a[idx].scrollIntoView();
});



/*
##################################################################
function to trigger image load and remove events
##################################################################
*/
function loadNewImage(new_item) {
    if (new_item instanceof Element) {
        // source attribute hold image item id without url
        var new_image = new_item.getAttribute("source");
        if (new_image.includes("api.digitale-sammlungen.de")) {
            new_image = `${new_image}/full/full/0/default.jpg`;
        } else if (new_image.includes("hsl-nfp")) {
            new_image = `https://iiif.acdh.oeaw.ac.at/iiif/images/${new_image}.jp2/full/full/0/default.jpg`;
        } else if (new_image.includes("hsl-vms")) {
            new_image = `https://iiif.acdh.oeaw.ac.at/iiif/images/${new_image}.jp2/full/full/0/default.jpg`;
        } 
        else if (new_image.includes("hsl-doc")) {
            if (new_image.endsWith(".jpg")) {
            new_image = new_image.slice(0, -4); // removes the last 4 characters (".jpg")
            };
            new_image = `https://iiif.acdh.oeaw.ac.at/iiif/images/${new_image}.jp2/full/full/0/default.jpg`; 
            }
        else {
            var new_image = `${new_image}?format=iiif`;
        }
        var old_image = viewer.world.getItemAt(0);
        if (old_image) {
            // access osd viewer and add simple image and remove current image
            viewer.addSimpleImage({
                url: new_image,
                success: function(event) {
                    function ready() {
                        setTimeout(() => {
                            viewer.world.removeItem(viewer.world.getItemAt(0));
                        }, 200)
                    }
                    // test if item was loaded and trigger function to remove previous item
                    if (event.item) {
                        // .getFullyLoaded()
                        ready();
                    } else {
                        event.item.addOnceHandler('fully-loaded-change', ready());
                    }
                }
            });
        }
    }
}

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
    ) {
        return true;
    } else {
        return false;
    }
}

/*
##################################################################
function to check if element is anywhere in window viewport
##################################################################
*/
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