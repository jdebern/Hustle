extends Node
#     Pixel Perfect ( Hopefully that's not a trademarked name )

# An easy plug and play script for pixel games in Godot, allowing the art to stay clean and crisp.

# Allows Pixel art games to be scaleable.
# It does so by only letting the main displayed viewport be 
# scaled by intiger increments that fits inside the window.
# Doing so while allowing the window to be distorted by any means
# to fit a screen, such that it works in full screen Mode as well.

# Note: If the window is distorted, or if the game is made in a
#     resolution that does not fit the monitor when in full screen
#     mode, unnused space will be left as black nothingness. 
#     Black should work in most cases. Not sure if this background 
#     can be colored. If not, users may need to make a custom 
#     viewport  per scene and not this script if they want the 
#     power to customize the unused space (scaleable pixel art?)

# Original code by Reddit User CowThing (July? 2017)
# https://www.reddit.com/r/godot/comments/6hizdx/window_resolution_control

# Not sure if it is 3.0.1 but the code had some issues
# Code found and cleaned up by Reddit User (me) Saki_Sliz (April 2018)

# How To install:

#     Get the code saved:
#         Go to your game.
#         Go to script viewer (top middle icons)
#         Click file
#         Click new
#         Before clicking Confirm, click in the "Path" text box
#         Give the new file a reasonable name, ie "Pixel Perfect.gd"
#         Confirm defaulte GDscript options
#         Select all the default code
#         Erase all the code
#         Copy and paste this script into the code (make sure to include the first "extends Node" line)
#         save (I do Save All Scenes)

#     Get Pixel Snap Activated:
#         Navigate (Godot 3.0.1) to Project tab (Top Left)
#         Select "Project Settings"
#         Go to Rendering --> Quality (Left side list)
#         Find "Use Pixel Snap" (4th option)
#         Make sure "Use Pixel Snap" Has a check in the Text box next to "on" 
#         Checkbox found on the same line to the right of the window
#         (Set Framebuffer Allocation to 2D as well?)

#     Customize Window Settings:
#         While still in "Project Settings" Window
#         Go to Display --> Window (Left side list)
#         Find "Width" and "Height"
#         Adjusting these two numbers will set what resolution 
#         your game will be rendered at.
#         (if you want your game to start out bigger scale
#         The first variable in this script can be adjusted
#         to fit the scale you want, Whole numbers Best results)
#         "Resizeable" determines if users can reshape the window
#         It is possible to Disable this, and still have the code
#         reshape the window as needed (such as in an option menu)

#     CRITICAL!!!

#         In order for this script to do its magic, 
#         on the same list of option,
#         in the last section 
#         Display --> Window //> Stretch
#         There is the option called "Mode"
#         Set this to "viewport"

#     Finally, Enabling this Script
#         To have this script work in all parts of your game
#         (ie, not just work for one level)
#         With the Project Settings window still open,
#         Select "AutoLoad" in the list of tags at the top.
#         Go to the right of the "Path" text box
#         Click the small box with two " .. "
#         browse for the saved script.
#         Confirm selection, and return to 
#         Project Settings -> AutoLoad
#         In the "Node" text box, name the node  [THIS NAME IS IMPORTANT]---> |
#         (start with letters, no spaces)                                     |
#         Click Add                                                           |
#         The node will be already enabled                                    |
#         Close "Project Settings"                                            |
#         Save game scenes                                                    |
#         Test                                                                |
#         Smile                                                               |
#                                            [USE SAME NAME IN get_node()]--> |
# Functions                                                                   |
#     There is a start up function                                            |
#     A function for handling screen resizing (no need to touch this)         |
#     Two functions you can use to adjust the screen on the fly               V
#         1 allows direct control over the saze of the window 
#             get_tree().get_root().get_node("PixelPerfect").new_window_size( Vector2 ):
#         Second allows for similar control, using specific intigers of scale
#             get_tree().get_root().get_node("PixelPerfect").new_window_scale( int ):
#     1 hidden function that does the magic that makes things Pixel Perfect

#     Example code:
#     func _on_Button_Make_Small():
#         var game = get_tree().get_root().get_node("PixelPerfect")
#         game.new_window_scale(1) # Sets the game to its true size

# 1 Variable
#     The only variable here, is a variable to set what scale the game starts out at

# Best Of Luck!

# ONLY Variable, Defines what scale to start the game at
# For me, Pixel games only work on CRTs or if they are enlarge
# digital pixels are too hard to view and I'm 22
onready var start_up_scale = 2

# For easy referencing
onready var root = get_tree().get_root() # for easy refferencing of the root
onready var base_size = root.get_size(); # allows for using the editor to program the game size, and the code will adapt without need for editing
#Possible to acces base_size??? to allow users to adjust the rendering of their game on the fly????

var fullscreen : bool = false
var scale : int = 0


# Start up code
func _ready():
	assert( get_tree().connect("screen_resized", self, "_on_screen_resized") == OK ) # makes a signal to allow for the detection of screen resizing
	root.set_size_override_stretch(false) # prevents the viewport from being warped
	new_window_scale(start_up_scale) # uses it's own built in functions to do the work

	pass # _ready()


func _on_screen_resized(): # this is the set of code asociated with screen being resized by users (checks to see how we will handle resizing)
	var adjusted_window_size = OS.get_window_size() # Get the size information so we know what to do with it.
	_no_center_new_window_size(adjusted_window_size) # automaticed function will do the work, 
	# if users are adjusting the window manually, don't center, let users control it how they want it.

	pass # _on_screen_resized()


func new_window_size( new_size ): # Put in a size for your game in pixel, and this function will do the rest
	OS.set_window_size(Vector2(max(base_size.x, new_size.x), max(base_size.y, new_size.y))) 
	OS.center_window() # Centers the window since this is usually desirable
	# Used resize the window, either just keeping the new size, or making sure that the size never is smaller than the true resolution
	_refresh_draw_scale( new_size ) # inform the super important function about the new size.

	pass # new_window_size()


func _no_center_new_window_size( new_size ): # Put in a size for your game in pixel, and this function will do the rest
	OS.set_window_size(Vector2(max(base_size.x, new_size.x), max(base_size.y, new_size.y))) 
	# take this out OS.center_window() # Centers the window since this is usually desirable
	# Used resize the window, either just keeping the new size, or making sure that the size never is smaller than the true resolution
	_refresh_draw_scale( new_size ) # inform the super important function about the new size.

	pass # _no_center_new_window_size()


func new_window_scale( new_scale ): # Put in a size for a window, and this function will do the rest
	if new_scale == scale:
		return

	var new_size = base_size * new_scale # does math for making it so screen is in normal pixels, not big pixels
	new_window_size(new_size) # Use our ready made function to handle the rest
	scale = new_scale

	pass # new_window_scale()
	

func _refresh_draw_scale( window_size ): # Where the magic happens
	var scale_w = max(int(window_size.x / base_size.x), 1) # How much can we fit side to side?
	var scale_h = max(int(window_size.y / base_size.y), 1) # How much can we fit top to bottom?
	var scale = min(scale_w, scale_h) # Which can we fit the least in to get the best effect?

	var best_size = base_size * scale # Time to scale the render, making sure to so in small normal pixel units

	var diff = window_size - (best_size) # calculate unused space
	var diffhalf = (diff * 0.5).floor() #cut that space in half, so our render is in the middel of the unused space, 
    #round down to keep the pixel art as crisp as possible

	var fresh_Window = Rect2(diffhalf, best_size) # Now we know where and what we want to draw
	root.set_attach_to_screen_rect(fresh_Window) # Finaly we make the update call and ditch this place

	pass # _refresh_draw_scale()

	
func set_fullscreen( enable ):
	OS.set_window_fullscreen( enable )
	fullscreen = enable

	pass # set_fullscreen()

