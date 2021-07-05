/*
#####################
#  print settings : #
#####################

anemometer cups : 94.5x50x25mm(6.6g pla) => 
====================
no support
infill density : 30%
infill pattern : cubic subdivision

anemometer axle : 25x25x20mm (4.1g pla)
====================
no support
infill density : 30%
infill pattern : cubic subdivision

anemometer_rotary_encoder : 35x35x8mm (2g pla)
====================
no support


direction vane : 110x60x12mm (12g pla)
====================
no support

body bottom : 95x77x30mm (21g pla)
====================
no support or [support, no tower] depend on the printer


body top : 81x81x40mm (35g pla)
====================
no support
raft (optional)

outer pipe : 16x16x102mm (9g pla)
====================
no support
combining mode : not in skin


####Anemometer calculus : 

https://fr.wikipedia.org/wiki/An%C3%A9mom%C3%A8tre#An%C3%A9mom%C3%A8tre_%C3%A0_coupelles_(dit_de_Robinson)


[Wind speed in m/s] = 2PI * [anemometer mid cup to axle lenght in m]  * [revolution per seconds]  * [unknown correction factor]

anemometer mid cup to axle lenght = 72.5 mm => 72.5/1000 = 0.0725 m for R

rotary encoder pulse per revolution : 36

revolution per seconds = pulses /36 /60
S = 2PI * 0.0725 * pulses /36 /60 = 0.00021089395

Speed m/s => Km/h : *3.6 => 0.00075921822

[unknown correction factor or friction] = ~5 => 0.00075921822 *5

*/

// Use thread library from http://dkprojects.net/openscad-threads/
include <threads.scad>;

//###############
//#### Parametric 

/* [anemometer cup] */
number_of_cups=3;//number of cup
cup_diameter=50; // [10:5:100]
cup_height=25; // [10:5:50]
cup_tickness=1.00; //[0.75:0.25:3.5]

arm_tickness=3.5; //[1.25:0.25:5.5]
arm_length=50; // [30:5:150]
arm_scale_height=5; //[1:1:12]
arm_scale_width=1.5; //[0.25:0.25:5]
arm_cylinder_length=5; // [2:1:10]
arm_screw_diam=2.9; //[1:1:5]

/* [anemometer axle] */
anemometer_axle_diameter=25; // [10:1:35]
anemometer_axle_height=20; // [10:1:30]
anemometer_axle_angle=10; // [0:1:45]

//anemometer_axle_joint_scale=1.075; // [0.9:0.0025:1.25]
//1.05 too thin
//1.15 too large

/* [anemometer rotary encoders] */
anemometer_rotary_encoder_pulses_per_revolution=36;// [2:2:36]
anemometer_rotary_encoder_height=1.5;// [0.5:0.5:3]
anemometer_rotary_encoder_diam=35;// [10:5:70]



/* [weather_station case] */

weather_station_diam=75; // [50:5:100]
weather_station_tickness=1.50; //[0.50:0.25:5.5]
weather_station_bottom_height=30; // [15:5:60]
weather_station_top_height=40; // [15:5:60]
ball_bearing_diam=11; // [10:1:30]
ball_bearing_height=8; // [6:1:10]
mounting_pipe_inner_diam=13;//[10:1:20]
mounting_pipe_lenght=100; //[80:10:180]
mounting_pipe_support_lenght=30; //[30:10:50]
mounting_pipe_angle=-15;
//mounting_pipe_outer_diam=16;
//hang_pipe_lenght=80; //[70:10:150]

/* [vane] */
vane_blade_lenght=80; //[30:1:150]
vane_blade_height=60; //[30:1:150]
vane_blade_tickness=2; //[1:1:5]




/* [rendering] */

render="all"; //[anemometer_cup,anemometer_axle,anemometer_rotary_encoders,weather_station_bottom,weather_station_top,direction_vane,optical_sensor_support,pipe_hang,outer_pipe,all,bottom_only,top_only,pipe_hang_adjustement]

$fn=200;
debug=false;

/* [Hidden] */
pla_retraction=0.5;
screw_length=20;
screw_diam=5;
//https://itafasteners.com/products-bolts-hex-head-anchor-bolts.php
screw_bolt_tolerance=0.25;
screw_bolt_diam=8.79+screw_bolt_tolerance;//+pla_retraction;
screw_bolt_height=3.5;
threads_pitch = 1.5;//weather_station_tickness/2;//1.5;

//calculus : 

anemometer_axis_dist=(cup_diameter/2+arm_length+anemometer_axle_diameter/2-15)*cos(anemometer_axle_angle*PI/180);//mm
anemometer_max_rps=50*1/(anemometer_axis_dist/1000*PI);//rotation per second at 50m/s = 180km/h
anemometer_cup_weight=6.6;



echo("anemometer mid cup to axle lenght=",anemometer_axis_dist ,"mm");

echo("anemometer max rps at 50m/s(180km/h)=",
    anemometer_max_rps*60, "rpm or", anemometer_max_rps, "r/sec" );
    
    
echo("max encoder Hz at 50m/s=",
    anemometer_max_rps *anemometer_rotary_encoder_pulses_per_revolution, "Hz (must be < 76923Hz = 13µs esp32 limit)" );

echo("Centrifugal force for a ",anemometer_cup_weight,"g cup at 50m/s=",
    (anemometer_cup_weight/1000 *(50^2))/(anemometer_axis_dist/1000), " N (must be < 250 N PLA traction resitance)" );//FC = mv²/R.
    
echo("Anemometer wind speed factor ([Wind speed in m/s] = 2PI * [anemometer mid cup to axle lenght in m] /2 * [revolution per seconds] ): ",2*PI* anemometer_axis_dist/1000 /anemometer_rotary_encoder_pulses_per_revolution /60 );



if (render=="all") {
   
    $fn=30;
    
    //cups axle
    translate([0,0,-anemometer_axle_height])anemometer_axle();
    
    //cups
    for ( i = [0 : number_of_cups-1] )
    {
    rotate( i * 360 / number_of_cups, [0, 0, 1])
    translate([-arm_length-anemometer_axle_diameter,anemometer_axle_diameter,-anemometer_axle_height])
        rotate([90,-anemometer_axle_angle,0])
   anemometer_cup(); 
    }
    
    
    //body bottom
    color( "PowderBlue", 0.8 )
   weather_station_bottom();
    //encoder
    color( "green", 0.8 )
    //translate([0,0,ball_bearing_height+2*screw_bolt_height+3])
    //rotate([180,0,0])
    translate([0,0,ball_bearing_height+weather_station_tickness])
    anemometer_rotary_encoders();
    //optical sensor
    color( "Lime", 0.8 )
    //translate([-10,anemometer_rotary_encoder_diam/2+2,ball_bearing_height+2*screw_bolt_height+3])
    translate([-12,anemometer_rotary_encoder_diam/2+3,ball_bearing_height+2])rotate([180,0,0])
    pcb_optical_sensor();
    
    //esp32
    //translate([0,0,ball_bearing_height*2+2*screw_bolt_height+15])color( "Gold", 0.8 )pcb_esp32();
    
    //body top
    color( "SkyBlue", 0.8 )
    translate([0,0,weather_station_bottom_height+weather_station_top_height-10])
    rotate([180,0,0])
    weather_station_top();
    
    
    //direction_vane
    color( "SandyBrown", 0.8 )
    translate([0,0,weather_station_bottom_height+weather_station_top_height-10])
    rotate([90,0,0])
    direction_vane();
    
        //outer_pipe
    color( "SkyBlue", 0.5 )
    rotate([0,0,90])translate([weather_station_diam/2+mounting_pipe_support_lenght/2-3,0,weather_station_bottom_height/2-3])rotate([0,90,0])rotate([0,mounting_pipe_angle,0])outer_pipe();
    
    //pipe_hang
    color( "Orchid", 0.8 )
    rotate([0,0,90])translate([weather_station_diam/2+mounting_pipe_support_lenght*4,0,weather_station_bottom_height/2-4+mounting_pipe_support_lenght])rotate([0,270,0])pipe_hang();
    
}

if (render=="bottom_only") {
   
    $fn=30;
    
    //cups axle
    translate([0,0,-anemometer_axle_height])anemometer_axle();
    
    //cups
    for ( i = [0 : number_of_cups-1] )
    {
    rotate( i * 360 / number_of_cups, [0, 0, 1])
    translate([-arm_length-anemometer_axle_diameter,anemometer_axle_diameter,-anemometer_axle_height])
        rotate([90,-anemometer_axle_angle,0])
   anemometer_cup(); 
    }
    
    
    //body bottom
    color( "PowderBlue", 0.8 )
   weather_station_bottom();
    //encoder
    color( "green", 0.8 )
    //translate([0,0,ball_bearing_height+2*screw_bolt_height+3])
    //rotate([180,0,0])
    translate([0,0,ball_bearing_height+weather_station_tickness])
    anemometer_rotary_encoders();
    //optical sensor
    color( "Lime", 0.8 )
    //translate([-10,anemometer_rotary_encoder_diam/2+2,ball_bearing_height+2*screw_bolt_height+3])
    translate([-12,anemometer_rotary_encoder_diam/2+3,ball_bearing_height+7])rotate([180,0,0])
    pcb_optical_sensor();
    
    
    color( "Orchid", 0.8 )
    translate([-27,anemometer_rotary_encoder_diam/2+4,ball_bearing_height-3])
    optical_sensor_support();
    
    //esp32
    //translate([0,0,ball_bearing_height*2+2*screw_bolt_height+15])color( "Gold", 0.8 )pcb_esp32();
    
    //outer_pipe
    color( "SkyBlue", 0.5 )
    rotate([0,0,90])translate([weather_station_diam/2+mounting_pipe_support_lenght/2-3,0,weather_station_bottom_height/2-3])rotate([0,90,0])rotate([0,mounting_pipe_angle,0])outer_pipe();
    
    //pipe_hang
    color( "Orchid", 0.8 )
    rotate([0,0,90])translate([weather_station_diam/2+mounting_pipe_support_lenght*4,0,weather_station_bottom_height/2-4+mounting_pipe_support_lenght])rotate([0,270,0])pipe_hang();
    
    
}

if (render=="top_only") {
   
    $fn=30;
    
    
    //body top
    color( "SkyBlue", 0.3 )
    translate([0,0,weather_station_bottom_height+weather_station_top_height-10])
    rotate([180,0,0])
    weather_station_top();
    
    
    //direction_vane
    color( "SandyBrown", 0.6 )
    translate([0,0,weather_station_bottom_height+weather_station_top_height-10])
    rotate([90,0,0])
    direction_vane();
    
    //weight compensation
    //color( "green", 0.8 )    translate([-38,-6,weather_station_bottom_height+weather_station_top_height-3])rotate([90,0,90])cylinder(r=screw_bolt_diam/2,h=screw_bolt_height*2+20,$fn=6);
    
    //magnet
    //color( "red", 0.8 )    translate([-34,-6,weather_station_bottom_height+weather_station_top_height])rotate([0,0,0])cylinder(r=screw_bolt_diam/2,h=2,$fn=30);

}


if (render=="anemometer_cup") {
        
    if(debug==true){
        difference(){
        translate([cup_diameter/2,0,cup_height])rotate([-180,0,0])anemometer_cup();
            cube(150, center=true);
        }
        
    }else{
    translate([cup_diameter/2,0,cup_height])rotate([-180,0,0])anemometer_cup();
    }
    
}

if (render=="anemometer_axle") {
        anemometer_axle();
}

if (render=="weather_station_bottom") {
        weather_station_bottom();
}

if (render=="anemometer_rotary_encoders"){
    anemometer_rotary_encoders();
}


if (render=="weather_station_top") {
        
    difference(){
        weather_station_top();
        //compass(height,diam,num)
        compass(0.5,weather_station_diam/2-3,8);
    }
}



if (render=="direction_vane") {
        direction_vane();
}

if (render=="pcb_optical_sensor") {
        pcb_optical_sensor();
}

if (render=="optical_sensor_support") {
        optical_sensor_support();
}

if (render=="pipe_hang") {
        pipe_hang();
}

if (render=="pipe_hang_adjustement") {
        pipe_hang_adjustement();
}

if (render=="outer_pipe") {
        outer_pipe();
}


//###################
//#### Vane

module direction_vane(){

    
    //echo("blade volume right = ", vane_blade_tickness*vane_blade_lenght*vane_blade_height/1000+(vane_blade_lenght-10)^2/1000+(vane_blade_height*2*vane_blade_tickness*2)/1000, "cm3");
    
    
    //echo("compensator volume left = ", ((vane_blade_lenght-10)*2*10)/1000, "cm3");
    
    difference(){
        
    union(){//right blade with axle
    //right blade
    linear_extrude(height=vane_blade_tickness){
    polygon(points=[[0,0],[vane_blade_lenght,0],[vane_blade_lenght+0,vane_blade_height],[60,vane_blade_height]]);
    }//linear_extrude
    
    //support horizontal right
    translate([10,0,0])
    cube([vane_blade_lenght-10,2,10]);
    
    //support vertical right
    translate([vane_blade_lenght,0,0])
    rotate([0,0,90])
    cube([vane_blade_height,2,vane_blade_tickness*2]);
    
    
    //left compensator
    translate([-30,0,0])cube([30,screw_diam*2+2,screw_diam*2+2]);
    
    //axle cube
    cube([screw_diam*2+2,screw_diam*2+2,screw_diam*2+2]);
    }//union
    

     //axle hex screw
         translate([screw_bolt_diam/2+1, screw_bolt_diam-0.5,screw_bolt_diam/2+1])
         rotate([90,30,0])
cylinder(r=screw_bolt_diam/2,h=screw_bolt_height*2+2,$fn=6);
    
    //compensator hex screw
         translate([-30, screw_bolt_diam/2+1,screw_bolt_diam/2+1])
         rotate([90,30,90])
cylinder(r=screw_bolt_diam/2,h=30,$fn=6);
         
     //top fix axle screw
     translate([screw_bolt_height*2+5, screw_bolt_height*2-1.5, screw_bolt_height*2-1])rotate([0,90,0])
cylinder(h=10,r=arm_screw_diam/2, center= true);
         
         
    }//diff
    
}



//###################
//#### Anemometer cup


module anemometer_cup(){
   
    color("blue",0.6)
    difference(){
        
        union(){
    //outer cup     
    rotate_extrude($fn=80) cone(cup_diameter/2,cup_height,2);
    
    //arm
    translate([arm_length-arm_tickness-10,0,cup_height])rotate(a=90, v=[1,0,0])rotate([0,90,0]) 
            
    union(){ 
    //arm horizontal reinforcement 
    translate([0,cup_diameter/3.5, cup_diameter/3])    rotate([0,202,90])    linear_extrude(height = arm_length, center = false, convexity = 10, scale=[arm_scale_width*2,arm_scale_height/2], $fn=100) circle(r = arm_tickness);
        
     //arm vertical on cup  
    translate([0, 0, cup_diameter/2])    rotate([0,180,0])linear_extrude(height = arm_length, center = false, convexity = 10, scale=[arm_scale_width,arm_scale_height], $fn=100) circle(r = arm_tickness);

    //arm vertical on joint 
    translate([0, 0, -cup_diameter/2])    linear_extrude(height = arm_length, center = false, convexity = 10, scale=[arm_scale_width/1.5,arm_tickness/2-0.10], $fn=100) circle(r = arm_tickness); 
       
    //reinforcment arm on joint

    rotate([0,0,90])translate([0, 0, -cup_diameter/2])
     linear_extrude(height = arm_length, center = false, convexity = 10, scale=[arm_scale_width/1.5+0.7,arm_tickness/2-0.10+0.45], $fn=100) circle(r = arm_tickness); 
      
        translate([-15/2, 0, cup_diameter/2])rotate([0,0,-90])
        cup_joint();
      
        
}//union arm();
            
        }//union cup + arm
        
        
    //cut inner cup
    translate([0,0,cup_tickness*2])    
    rotate_extrude($fn=80) cone(cup_diameter/2,cup_height,2);
        
    //cut arm bottom
    translate([0,-arm_length,cup_height])cube(arm_length+100);
    
        
    }//difference
    
    

}

module cup_joint(cut=false){
    
    
    tol = 0;
    extra_h = 0;
    
    if(cut == true){
        tol = pla_retraction/2;
        extra_h = 10;
    translate([0,0,-extra_h])    
    cube([6+tol,15+extra_h,5+tol+extra_h],false);
    translate([0,0,4])
    cube([10+tol,15+extra_h,4+tol],false);
        
    }else{
        cube([6,15,5],false);
    translate([0,0,4])
    cube([10,15,4],false);
    }
    
}

//###################
//#### Anemometer axle

module anemometer_axle(){

    
difference() {
       
  //outer axle  
    color("Violet",0.25)
cylinder(h = anemometer_axle_height, r=anemometer_axle_diameter/2, center =false);
   
for ( i = [0 : number_of_cups-1] )
{
    
    extra_h = 10;
    rotate( i * 360 / number_of_cups, [0, 0, 1])translate(v = [anemometer_axle_diameter/2+1, arm_tickness, arm_tickness/2])   rotate([0,270,90 / number_of_cups+number_of_cups^2]) rotate([anemometer_axle_angle,0,90])
    translate([0, -extra_h+2.25-7.5-anemometer_axle_height/2, 1]) cup_joint(cut=true); //todo : fix height from angle


}//end for cube


 //hex screw
translate([0, 0, anemometer_axle_height/2+2])
cylinder(r=screw_bolt_diam/2,h=screw_bolt_height*2+1+2,$fn=6);


 //top fix axle screw v0 (until v97)
//translate([0, anemometer_axle_height/2, anemometer_axle_height/2+screw_bolt_height+1])rotate([90,0,0])cylinder(h=15,r=arm_screw_diam/2, center= true);

 //top fix axle screw 1
translate([0, anemometer_axle_height/2, anemometer_axle_height/2+1+screw_bolt_height+1])rotate([90,0,0])cylinder(h=15,r=arm_screw_diam/2, center= true);

 //top fix axle screw 2
rotate( 120, [0, 0, 1])translate([0, anemometer_axle_height/2, anemometer_axle_height/2+1+screw_bolt_height+1])rotate([90,0,0])cylinder(h=15,r=arm_screw_diam/2, center= true);

 //top fix axle screw 3
rotate( 240, [0, 0, 1])translate([0, anemometer_axle_height/2, anemometer_axle_height/2+1+screw_bolt_height+1])rotate([90,0,0])cylinder(h=15,r=arm_screw_diam/2, center= true);

//top spacer
translate([0, 0, anemometer_axle_height-1])
difference(){

cylinder(r=anemometer_axle_diameter/2+1,h=screw_bolt_height*2+1,$fn=30);
    
 cylinder(r=anemometer_axle_diameter/2/2,h=screw_bolt_height*2+1,$fn=30);
    
}

}//difference

}//anemometer_axle


//###################
//#### pcb_optical_sensor

module pcb_optical_sensor(){
    
    //pcb : (32x14x1.8mm) 
    cube([32,1.5,14], center=true);
  // sensors : (14x10x6mm)
   translate([32/2-3,6,0])    cube([6,10,14], center=true);

    
}    

module optical_sensor_support(){
    
    //pcb : (32x14x1.8mm) 
    cube([32,1.5,14+5], center=false);
    
    //translate([0,5,0])rotate([90,0,0])    cube([32,1.5,10], center=false);
    
    translate([0,1.5,0])rotate([90,0,0])cube([32,2.6,4], center=false);
    
    translate([20,7.5,0])rotate([90,0,0])cube([12,2.6,10], center=false);

   //translate([32/2-3,6,0])    cube([6,10,14], center=true);

    
}   



//###################
//#### pcb_esp32

module pcb_esp32(){
    
    //pcb : (60x30x30mm) 
    cube([60,30,30], center=true);
    
}    


//###################
//#### weather_station_bottom

module weather_station_bottom(){
  
    if(debug == true){
        //main cylinder
    difference(){
    
    union(){
    //outer cylinder    
    cylinder(h=10,r=weather_station_diam/2, center=false);
    
    //exterior threads  
    metric_thread (diameter=weather_station_diam+threads_pitch, pitch=threads_pitch, length=10,internal=false); 
    
    //translate([0,weather_station_diam/2-4,anemometer_rotary_encoder_height])      pcb_optical_sensor();
        
    }
        
      //inner cylinder
    cylinder(h=weather_station_bottom_height,r=weather_station_diam/2-weather_station_tickness/2, center=false);  

    }//difference
    
    
    //translate([0,weather_station_diam/2-4,anemometer_rotary_encoder_height])      pcb_optical_sensor();
    
    
    }else{//not debug    

    //////////////////////
    //main cylinder
    difference(){
    
        union(){
    //outer cylinder    
    cylinder(h=weather_station_bottom_height,r=weather_station_diam/2, center=false);
      
    //exterior threads  
    translate([0, 0, weather_station_bottom_height-10])    //color("yellow",0.3)
    metric_thread (diameter=weather_station_diam+threads_pitch, pitch=threads_pitch, length=10,internal=false);   
    // internal -    true = clearances for internal thread (e.g., a nut).
//               false = clearances for external thread (e.g., a bolt). 
         
    //mounting pipe  
    //rotate([0,0,90])translate([weather_station_diam/2+mounting_pipe_support_lenght/2-3,0,weather_station_bottom_height/2-3])rotate([0,90,0])rotate([0,mounting_pipe_angle,0])    cylinder(h=mounting_pipe_support_lenght, d=mounting_pipe_inner_diam, center=true);        
     
    rotate([0,0,90])translate([weather_station_diam/2+mounting_pipe_support_lenght/2-3,0,weather_station_bottom_height/2-3])rotate([0,90,0])rotate([0,mounting_pipe_angle,0])cube([mounting_pipe_inner_diam, mounting_pipe_inner_diam,mounting_pipe_support_lenght],center=true);       
            
        }
        
    //inner cylinder
    translate([0, 0, weather_station_tickness])    
    cylinder(h=weather_station_bottom_height,r=weather_station_diam/2-weather_station_tickness/2, center=false);
        
    //ball bearing hole
   
    cylinder(h=ball_bearing_height+1,r=ball_bearing_diam/2+pla_retraction, center=false);  
    //+pla_retraction/2
        
    //threads
    //translate([0, 0, weather_station_bottom_height-10])    color("yellow",0.6)metric_thread (diameter=weather_station_diam, pitch=threads_pitch, length=10,internal=false);   
       
    //mounting pipe hole 
    rotate([0,0,90])translate([weather_station_diam/2+mounting_pipe_support_lenght/2-2,0,weather_station_bottom_height/2-3])rotate([0,90,0])rotate([0,mounting_pipe_angle,0])
    cylinder(h=mounting_pipe_support_lenght, d=mounting_pipe_inner_diam-weather_station_tickness*2, center=true);    
        
    }//diff main cylinder
  
  
    /////////////////////////
    //ball bearing hang
    
    difference(){

   union(){ 
    //outer cylinder    
    cylinder(h=ball_bearing_height,r=ball_bearing_diam/2+weather_station_tickness*2, center=false);
       
    //bottom reinforcement
    for ( i = [0 : number_of_cups-1] )
{
    
    rotate( i * 360 / number_of_cups, [0, 0, 1])
    translate([0, 0, ball_bearing_height/2])cube([weather_station_diam-weather_station_tickness,weather_station_tickness,ball_bearing_height-weather_station_tickness],center=true);
}
       
   }//union
        
    //inner cylinder
   
    cylinder(h=ball_bearing_height+1,r=ball_bearing_diam/2+pla_retraction/2, center=false);
   //+pla_retraction/2
   
     // bearing screw
    translate([0, screw_bolt_height*2, screw_bolt_height*3/2-0.5])rotate([90,0,0])
cylinder(h=10,r=arm_screw_diam/2, center= true);
   
   //pcb cut
   translate([-10,anemometer_rotary_encoder_diam/2+3,weather_station_tickness+5])rotate([180,0,0])cube([20,10,10],center = true);
   //scale([1,1.5,1])pcb_optical_sensor();
        
    }//diff ball bearing
    
    
    //support for optical sensor pcb
 /*   //translate([0,weather_station_diam/2-4,anemometer_rotary_encoder_height+14]) 
    translate([-10,anemometer_rotary_encoder_diam/2+4,weather_station_bottom_height/2])cube([32,1.5,weather_station_bottom_height-weather_station_tickness], center=true);
    
     translate([-10,anemometer_rotary_encoder_diam/2+2.5,5.5])cube([32,2.5,11], center=true);
    
*/
    //rotary encoder protection (cables)
    difference(){
    cylinder(h=weather_station_bottom_height*2/3,d=anemometer_rotary_encoder_diam+5, center=false);
    
    cylinder(h=weather_station_bottom_height-weather_station_tickness,d=anemometer_rotary_encoder_diam+5-weather_station_tickness, center=false);   
       
    translate([-15,anemometer_rotary_encoder_diam/2-2,0])cube([30,10,weather_station_bottom_height-weather_station_tickness], center=false);    
        
    }//diff rotary encoder protection


}//debug

}//end module



//###################
//#### weather_station_top

module weather_station_top(){
    
    //$fn=30;
  
    if(debug == true){
        
        
    difference(){
    //outer cylinder    
    cylinder(h=10,r=weather_station_diam/2+threads_pitch+threads_pitch/2+weather_station_tickness/2, center=false);
        //+weather_station_tickness/2

    //inner cylinder
    //translate([0, 0, weather_station_tickness])cylinder(h=weather_station_top_height,r=weather_station_diam/2-weather_station_tickness/2+threads_pitch, center=false);
        
    //ball bearing hole
   
    //cylinder(h=ball_bearing_height+1,r=ball_bearing_diam/2+pla_retraction/2, center=false);  

        
    //threads
    translate([0, 0, 0])
        color("yellow",0.6)metric_thread (diameter=weather_station_diam+threads_pitch+threads_pitch/2+weather_station_tickness/2, pitch=threads_pitch, length=10,internal=true);    
        //+weather_station_tickness
        
    }//diff main cylinder
    
    
        
    }else{// end debug

    //////////////////////
    //main cylinder
    difference(){
    
        union(){
    //outer cylinder    
    cylinder(h=weather_station_top_height,r=weather_station_diam/2+threads_pitch+threads_pitch/2+weather_station_tickness/2, center=false);
    //echo(weather_station_diam/2+threads_pitch+threads_pitch/2+weather_station_tickness/2);        
            //weather_station_diam/2+threads_pitch/2+weather_station_tickness/2
            //+weather_station_tickness*1.5
    
    //top threads
    //echo(weather_station_diam/2+threads_pitch/2+weather_station_tickness/2);
            
    //bottom threads:
    //echo((weather_station_diam+threads_pitch+weather_station_tickness)/2);
      
    //exterior threads  
    //translate([0, 0, weather_station_top_height-10])    //color("yellow",0.3)    metric_thread (diameter=weather_station_diam+threads_pitch, pitch=threads_pitch, length=10,internal=false);  
            
    // internal -    true = clearances for internal thread (e.g., a nut).
//               false = clearances for external thread (e.g., a bolt).    
            
        }
        
    //inner cylinder
    translate([0, 0, weather_station_tickness])cylinder(h=weather_station_top_height-10-1,r=weather_station_diam/2-weather_station_tickness/2+threads_pitch/2, center=false);
        //+threads_pitch/2
    
    //echo(weather_station_diam/2-weather_station_tickness/2);
        
    //echo(weather_station_diam/2-weather_station_tickness/2+threads_pitch/2);    
        
    //ball bearing hole
   
    cylinder(h=ball_bearing_height+1,r=ball_bearing_diam/2+pla_retraction/2, center=false);  
    //+pla_retraction/2
        
    //threads
    translate([0, 0, weather_station_top_height-10])    color("yellow",0.6)metric_thread (diameter=weather_station_diam+threads_pitch+threads_pitch/2+weather_station_tickness/2, pitch=threads_pitch, length=10,internal=true);  
    //echo(weather_station_diam+threads_pitch+threads_pitch/2+weather_station_tickness/2);
        
    }//diff main cylinder
  
  
    /////////////////////////
    //ball bearing hang
    
    difference(){

   union(){ 
    //outer cylinder    
    cylinder(h=ball_bearing_height+5,r=ball_bearing_diam/2+weather_station_tickness*2+2, center=false);
       
    //bottom reinforcement
    for ( i = [0 : number_of_cups-1] )
{
    
    rotate( i * 360 / number_of_cups, [0, 0, 1])
    translate([0, 0, ball_bearing_height/2])cube([weather_station_diam-weather_station_tickness,weather_station_tickness,ball_bearing_height-weather_station_tickness],center=true);
}
       
   }//union
        
    //inner bearing cylinder
   
    cylinder(h=ball_bearing_height+1,r=ball_bearing_diam/2+pla_retraction/2, center=false);
   //+pla_retraction/2
   
     // bearing screw
    translate([0, screw_bolt_height*2, screw_bolt_height*3/2-0.5])rotate([90,0,0])
cylinder(h=10,r=arm_screw_diam/2, center= true);
   
   //pcb place (14x20mm)
   translate([0,0,12.5])
   cube([14,25,5],center=true);
   
        
    }//diff ball bearing

}//debug
}//end module






//###################
//#### anemometer_rotary_encoders

module anemometer_rotary_encoders(){
//if (render=="anemometer_rotary_encoders") {
    
     difference(){
         union(){
  color("Green",0.25)
     //axle cylinder
cylinder(h = screw_bolt_height*2+2, r=screw_bolt_diam/2+1, center =false);
             
   //perimeter cylinder
   difference(){          
   cylinder(h = anemometer_rotary_encoder_height, r=anemometer_rotary_encoder_diam/2, center =false); 
       
   cylinder(h = anemometer_rotary_encoder_height, r=anemometer_rotary_encoder_diam/2-anemometer_rotary_encoder_height/2, center =false);    

   }       
    
   color("Green",0.25)
    //rotary_encoders(height,diam,num)
    
    translate([0, 0, screw_bolt_height/2-1])    rotary_encoders(anemometer_rotary_encoder_height,anemometer_rotary_encoder_diam,anemometer_rotary_encoder_pulses_per_revolution);
             
    //top fix axle screw big
    translate([0, screw_bolt_height*2-1, screw_bolt_height*3/2-0.5])rotate([90,0,0])
cylinder(h=1,r=arm_screw_diam/2+1, center= true);         
         }
    
     //hex screw
     //translate([0, 0,1])cylinder(r=screw_bolt_diam/2,h=screw_bolt_height*2+1,$fn=6);
    //translate([0, 0,-screw_bolt_height/3])cylinder(r=screw_bolt_diam/2,h=screw_bolt_height*3,$fn=6);
    translate([0, 0,-screw_bolt_height/3])cylinder(r=screw_bolt_diam/2+pla_retraction/2,h=screw_bolt_height*3,$fn=6);
        //pla_retraction=0.5 
         
     //top fix axle screw
    translate([0, screw_bolt_height*2, screw_bolt_height*3/2-0.5])rotate([90,0,0])
cylinder(h=10,r=arm_screw_diam/2, center= true);
         
         
    }//diff
    
}//anemometer_rotary_encoders



//#rotary_encoders(2,20,36);

//###################
//#### rotary_encoders

//esp32 : The APB_CLK clock is running at 80 MHz. => has a default counting rate of 13us 
//https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/peripherals/pcnt.html
//esphome : On the ESP32, this value can not be higher than 13us, for the ESP8266 you can use larger intervals too
//LM393 :  Large signal response time is 300ns, small signal 1.3us




module rotary_encoders(height,diam,num){
    
    //l_arc = (2*PI*diam/2/360*degree); //(2*PI*R)/360*a
    circonference = 2*3.14*diam/2;

    //for ( i = [0 : 360/num-1] )
    for ( i = [0 : num] )
{
    
    rotate( i * 360 / num, [0, 0, 1])
    //translate([0, 0, ball_bearing_height/2])
    cube([circonference/(num*2)-pla_retraction,diam,height],center=true); //pla_retraction/2
    
} 
    
}//end module rotary_encoders



//###################
//#### functions and helpers

//https://www.thingiverse.com/groups/openscad/forums/general/topic:12180
module cone(width=10, height=10, steps=1) {

k = (pow(width, 2) / height);
//echo (k);
function f(x) = pow(x,2)/k;

points = [
for (x=[0:1/steps:width]) [x,f(x)],
[0,f(width)]
];
paths = [
for (i=[0:(width*steps)+1]) i,
];

polygon(points,[paths]);
}






module dovetail_teeth(width, height, thickness) {
    offset = width / 3;
    {
        linear_extrude(height = thickness) {
            polygon([[0, 0], [width, 0], [width - offset, height], [offset, height]]);
        }
    }
}

module compass(height,diam,num){
    

    for(a=num) 
		for (i=[1:a])
		//rotate([0,0,360/a*i]) translate ([-0.35,diam,0])cube([.7,2,height]);
        rotate([0,0,360/a*i]) translate ([-0.35,diam,0])cube([1.0,2,height+0.5]);
                
    //North
    rotate([0,180,0]) translate ([-5.7,diam-10,-0.75])linear_extrude(height+0.75)             text("↑",size = 16,font = "Arial Bold:style=Bold"); 
    
   
                
                
}

module compass_with_cardinals(height,diam,num){
    

    for(a=num) 
		for (i=[1:a])
		//rotate([0,0,360/a*i]) translate ([-0.35,diam,0])cube([.7,2,height]);
        rotate([0,0,360/a*i]) translate ([-0.35,diam,0])cube([1.0,2,height+0.5]);
                
    //North
    rotate([0,180,0]) translate ([-2.5,diam-7,-0.75])linear_extrude(height+0.75)             text("N",size = 5,font = "Liberation Sans:style=Bold"); 
    //Est
    rotate([0,180,90]) translate ([-2.5,diam-7,-0.75])linear_extrude(height+0.75)             text("E",size = 5,font = "Liberation Sans:style=Bold"); 
        
   //South
    rotate([0,180,180]) translate ([-2.5,diam-7,-0.75])linear_extrude(height+0.75)             text("S",size = 5,font = "Liberation Sans:style=Bold"); 
        
   //West
    rotate([0,180,270]) translate ([-3.25,diam-7,-0.75])linear_extrude(height+0.75)             text("W",size = 5,font = "Liberation Sans:style=Bold");
   
                
                
}

module pipe_hang(){
    
    difference(){
    //mounting pipe outer

    //rotate([0,mounting_pipe_angle,0])    cylinder(h=mounting_pipe_support_lenght, d=mounting_pipe_inner_diam, center=false);
    
   translate([-mounting_pipe_inner_diam/2,-mounting_pipe_inner_diam/2,-weather_station_tickness*2+3.5])rotate([0,mounting_pipe_angle,0])    cube([mounting_pipe_inner_diam, mounting_pipe_inner_diam,mounting_pipe_support_lenght],center=false);
    
    
    //mounting pipe hole 
    //rotate([0,0,90])translate([weather_station_diam/2+mounting_pipe_support_lenght/2-2,0,weather_station_bottom_height/2-3])rotate([0,90,0])
    translate([-0.5,0,3.5])    
    rotate([0,mounting_pipe_angle,0])
    cylinder(h=mounting_pipe_support_lenght, d=mounting_pipe_inner_diam-weather_station_tickness*2, center=false);  
    }//diff
    
    //reinforcement
    translate([0,0,2.5])cube([20,20,5],center= true);
    
    difference(){
    cube([40,40,3.5],center= true);
    translate([15,0,1])rotate([0,0,90])    cube([40,5,1.5],center= true); 
        
    translate([-15,0,1])rotate([0,0,90])    cube([40,5,1.5],center= true);
    }//difference cube
}


module pipe_hang_adjustement(){

    difference(){
    //main cube 
    cube([40,40,10],center= false);
    
    //pipe_hang base plate
    angle = atan(6/40); //diff height/lenght
    rotate([angle,0,0])translate([-2.5,0,0.25])
    cube([45,45,10],center= false);
    
    //echo(angle, "°");
    }

}

module outer_pipe(){
    
    rotate([0,90,0])translate([-mounting_pipe_lenght/2,0,0])
    difference(){
    //mounting pipe outer


   cube([mounting_pipe_lenght+2,mounting_pipe_inner_diam+weather_station_tickness*2, mounting_pipe_inner_diam+weather_station_tickness*2],center=true);
   
   cube([mounting_pipe_lenght+2,mounting_pipe_inner_diam+pla_retraction, mounting_pipe_inner_diam+pla_retraction],center=true);
    
    
    }
}