class Result:
	var value: Variant
	var fault: int

	func is_none() -> bool:
		return fault != 0

	func is_some() -> bool:
		return fault == 0

	func take() -> Variant:
		assert(is_some(), "Fault `{0}` was detected.".format([fault]))
		return value

	func take_or() -> Variant:
		return value

static func some(value) -> Result:
	var result := Result.new()
	result.value = value
	return result

static func none(fault := 1) -> Result:
	var result := Result.new()
	result.fault = fault
	return result

static func test_script() -> void:
	assert(none().is_none() == true);
	assert(none().is_some() == false);
	assert(none().take_or() == null);
	assert(some(9).is_none() == false);
	assert(some(9).is_some() == true);
	assert(some(9).take_or() == 9);

