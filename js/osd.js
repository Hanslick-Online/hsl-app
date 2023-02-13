// change css styles to remove html images and set height for script repacement
var container = document.getElementById("container_facs_2");
container.style.display = "none";
// OpenSeaDragon Image Viewer
var height = screen.height;
// set osd container height
var container = document.getElementById("container_facs_1");
container.style.height = `${String(height - 400)}px`;
// set osd wrapper container width
var container = document.getElementById("section-1");
if (container !== null) {
    var width = container.clientWidth;
}
var container = document.getElementById("viewer-1");
container.style.width = `${String(width)}px`;

var tileSources = [];
var img = document.getElementsByClassName("tei-xml-images");
for (let i of img) {
    var image = i.getAttribute("dta-src");
    var imageURL = {type: 'image', url: image};
    tileSources.push(imageURL);
}

var viewer = OpenSeadragon({
    id: 'container_facs_1',
    prefixUrl: 'https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/',
    sequenceMode: true,
    showNavigator: true,
    imageLoaderLimit: 10,
    tileSources: tileSources
});
setTimeout(function() {
    document.getElementById("container_facs_2").remove();
}, 1000);