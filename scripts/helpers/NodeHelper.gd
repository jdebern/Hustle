extends Object

static func remove_children(node):
	for child in node.get_children():
		remove_child_by_node(node, child)

static func remove_child_by_node(node, child, force = true):
	if force:
		call('_remove_child_by_node', node, child, force)
	else:
		call_deferred('_remove_child_by_node', node, child, force)

static func _remove_child_by_node(node, child, force):
	if node_exists(node) and node_exists(child) and is_parent_of(node, child):
		node.remove_child(child)

		if force:
	        # If we force the deletion we need to be sure that the node is not blocked
	        # That is why we use 'queue_free'
			child.call_deferred('free')
		else:
			child.free()
	elif node_exists(child):
		if force:
        # If we force the deletion we need to be sure that the node is not blocked
        # That is why we use 'queue_free'
			child.call_deferred('free')
		else:
			child.free()
	else:
			logger.warning('You are trying to remove a null child')