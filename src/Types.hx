enum LayerType {
	IntGrid;
	Entities; // TODO temp
}


typedef IntGridValue = {
	var name : Null<String>;
	var color : UInt;
}

enum GlobalEvent {
	LayerDefChanged;
	LayerDefSorted;
	LayerContentChanged;

	EntityDefChanged;
	EntityDefSorted;
	EntityFieldChanged;
}

enum FieldType {
	F_Int;
	F_Float;
	F_String;
	F_Bool;
}