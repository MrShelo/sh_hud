
function isNumeric(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

function updatePlayerData(data){

    if ( data.show === false ) {
        $("#container").hide();
    } 
    else {
        $("#container").show();

    };
    
    if ( data.idlogo === false ) {
        $("#idlogo").hide();
    } 
    else {
        $("#idlogo").show();

    };

    if ( data.isVeh === false ) {
        $("#veh-container").hide(200);
    } 
    else {
        $("#veh-container").show(200);

    };

    if ( data.radioActive === false ) {
        $("#micicon").html("mic");
    } 
    else {
        $("#micicon").html("headset_mic");

    };
    
    $("#identifier").html(data.pid);
    $('#healthbox').height(data.health+"%");
    $('#armourbox').height(data.armor+"%");
    $('#staminabox').height(data.oxygen+"%");
    $('#eatbox').height(data.hunger+"%");
    $('#waterbox').height(data.thirst+"%");

    var voicebar = data.voice * 2
    if (voicebar > 10 ){
        voicebar = 100
    }
    else{
        voicebar = voicebar * 10 

    };
    $('#voicebox').height(voicebar+"%");
    if (data.talking)
    {
        $('#voicebox').css("background: linear-gradient(25deg, rgb(201, 142, 124) 0%, rgb(253, 91, 99) 100%)");
    }
    else
    {
        $('#voicebox').css("background: linear-gradient(25deg, rgb(254,124,40) 0%, rgba(233,159,111,1) 100%)");
    };
}
function updateCarData(data){
    if ( data.showcar === false ) {
        $("#veh-container").hide(200);
    } 
    else {
        $("#veh-container").show(200);
    };
    
    if ( data.seatbelt === false ){ 
        $('.seatbelt-fill').height("0%");
    }
    else{
        $('.seatbelt-fill').height("100%");
    };
    if (isNumeric(data.speed)){
        $('#speedinfo').html(data.speed + "MPH");
    }
    if (isNumeric(data.fuel)){
        var fuel = data.fuel.toString();
        $('.fuelbox-fill').height(data.fuel+"%");
    }
    $('#gearinfo').html(data.gear);
    $('#compassnames').html(data.navigation);
    $('#streetlabel').html(data.streetLabel);
}


window.addEventListener('message', function(event) {
    let data = event.data 
    switch (data.action) {
        case "car":
            updateCarData(data)
            break;
        case "hudtick":
            updatePlayerData(data)
            break;
        default:
            break;
    }


})