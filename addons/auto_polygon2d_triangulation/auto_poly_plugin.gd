@tool
extends EditorPlugin

var selected_polygon2d : Polygon2D = null
var previous_points : PackedVector2Array

var _polygon_2d_editor_panels : Array[Panel] = []


func _enter_tree() -> void:
	_polygon_2d_editor_panels = _get_polygon_2d_editor_panels()	


func _process(_delta: float) -> void:
	if selected_polygon2d == null:
		return
	if selected_polygon2d.polygon != previous_points:
		triangulate_polygons(selected_polygon2d)
		# queue the editor for redraw
		_queue_redraw_panels(_polygon_2d_editor_panels)
		
		previous_points = selected_polygon2d.polygon.duplicate()


func _handles(object: Object) -> bool:
	if object is Polygon2D:
		selected_polygon2d = object
		return true
	selected_polygon2d = null
	return false


func triangulate_polygons(polygon2d: Polygon2D) -> void:
	if polygon2d.polygon.size() < 3:
		return

	var indices: PackedInt32Array = Geometry2D.triangulate_delaunay(polygon2d.polygon) # indices into polygon2d.polygon :contentReference[oaicite:2]{index=2}

	# Outer vertices are stored at the beginning of polygon2d.polygon
	var outer_polygon: PackedVector2Array = polygon2d.polygon.slice(
		0,
		polygon2d.polygon.size() - polygon2d.internal_vertex_count
	)

	var new_polys: Array = [] # will contain PackedInt32Array items

	for i in range(0, indices.size(), 3):
		var ia := indices[i]
		var ib := indices[i + 1]
		var ic := indices[i + 2]

		var a: Vector2 = polygon2d.polygon[ia]
		var b: Vector2 = polygon2d.polygon[ib]
		var c: Vector2 = polygon2d.polygon[ic]

		if _points_are_inside_polygon(a, b, c, outer_polygon):
			new_polys.push_back(PackedInt32Array([ia, ib, ic])) # IMPORTANT: PackedInt32Array :contentReference[oaicite:3]{index=3}

	polygon2d.polygons = new_polys



# Find the Panels associated with the Polygon2DEditor node.
func _get_polygon_2d_editor_panels() -> Array[Panel] :
	var panels : Array[Panel] = []
	# Find the editor
	for child in get_editor_interface().get_base_control().find_children("*","Polygon2DEditor", true, false):
		# Find the "uv_edit_draw" panel https://github.com/godotengine/godot/blob/2a0aef5f0912b60f85c9e150cc0bfbeab7de6e40/editor/plugins/polygon_2d_editor_plugin.cpp#L1348
		# Note that this finds multiple panels as all of these nodes are nameless..
		panels.append_array(child.find_children("*", "Panel", true, false))
	return panels


func _queue_redraw_panels(panels: Array[Panel]) -> void:
	for panel in panels:
		if panel.is_visible_in_tree():
			panel.queue_redraw()


func _points_are_inside_polygon(a: Vector2, b: Vector2, c: Vector2, polygon: PackedVector2Array) -> bool:
	var center = (a + b + c) / 3
	# move points inside the triangle so we don't check for intersection with polygon edge
	a = a - (a - center).normalized() * 0.01
	b = b - (b - center).normalized() * 0.01
	c = c - (c - center).normalized() * 0.01
	
	return Geometry2D.is_point_in_polygon(a, polygon) \
		and Geometry2D.is_point_in_polygon(b, polygon) \
		and Geometry2D.is_point_in_polygon(c, polygon)
