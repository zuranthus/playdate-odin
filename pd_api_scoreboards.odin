package playdate





// pdext_scoreboards_h :: 

PDScore :: struct {}

PDScoresList :: struct {}

PDBoard :: struct {
	boardID: cstring,
	name:    cstring,
}

PDBoardsList :: struct {}

AddScoreCallback :: proc "c" (^PDScore, cstring)

PersonalBestCallback :: proc "c" (^PDScore, cstring)

BoardsListCallback :: proc "c" (^PDBoardsList, cstring)

ScoresCallback :: proc "c" (^PDScoresList, cstring)

scoreboards :: struct {
	addScore:        proc "c" (cstring, i32, AddScoreCallback) -> i32,
	getPersonalBest: proc "c" (cstring, PersonalBestCallback) -> i32,
	freeScore:       proc "c" (^PDScore),
	getScoreboards:  proc "c" (BoardsListCallback) -> i32,
	freeBoardsList:  proc "c" (^PDBoardsList),
	getScores:       proc "c" (cstring, ScoresCallback) -> i32,
	freeScoresList:  proc "c" (^PDScoresList),
}

