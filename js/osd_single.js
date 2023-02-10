// function load_image(facs_id, osd_container_id, osd_container_id2){
//     console.log(facs_id);
//     $('#' + osd_container_id).css({
//         'height': '400px'
//     });
//     // OpenSeaDragon Image Viewer
//     var image = $('#' + facs_id);
//     var image = image.attr('data-src');
//     var imageURL = {type: 'image', url: image};
//     var viewer = OpenSeadragon({
//         id: osd_container_id,
//         prefixUrl: 'https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/',
//         // sequenceMode: true,
//         // showReferenceStrip: true,
//         // showNavigator: true,
//         // imageLoaderLimit: 10,
//         tileSources: imageURL
//     });
//     $('#' + osd_container_id2).remove();
// };

var img = document.getElementsByClassName("tei-xml-images");
for (let i of img) {
    var container = i.parentNode.parentNode.parentNode.parentNode.parentNode.nextSibling.nextSibling;
    if (container !== null) {
        var height = container.clientHeight;
    }
    // let imd = i.id;
    let source = i.getAttribute("dta-source");
    let target = i.getAttribute("dta-target");
    document.getElementById(target).style.height = "400px";
    // OpenSeaDragon Image Viewer
    var image = i.getAttribute("dta-src");
    var image = image;
    var imageURL = {type: 'image', url: image};
    var viewer = OpenSeadragon({
        id: target,
        prefixUrl: 'https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/',
        // sequenceMode: true,
        // showReferenceStrip: true,
        // showNavigator: true,
        // imageLoaderLimit: 10,
        tileSources: imageURL
    });
    setTimeout(function() {
        document.getElementById(source).remove();

    }, 1000);
}