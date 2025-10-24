package playdate

PDScore :: struct {
	rank:   i32,
	value:  i32,
	player: cstring,
}

PDScoresList :: struct {
	boardID:        cstring,
	count:          u32,
	lastUpdated:    i32,
	playerIncluded: i32,
	limit:          u32,
	scores:         ^PDScore,
}

PDBoard :: struct {
	boardID: cstring,
	name:    cstring,
}

PDBoardsList :: struct {
	count:       u32,
	lastUpdated: i32,
	boards:      ^PDBoard,
}

AddScoreCallback     :: proc "c" (score: ^PDScore, errorMessage: cstring)
PersonalBestCallback :: proc "c" (score: ^PDScore, errorMessage: cstring)
BoardsListCallback   :: proc "c" (boards: ^PDBoardsList, errorMessage: cstring)
ScoresCallback       :: proc "c" (scores: ^PDScoresList, errorMessage: cstring)

scoreboards :: struct {
	addScore:        proc "c" (boardId: cstring, value: i32, callback: AddScoreCallback) -> i32,
	getPersonalBest: proc "c" (boardId: cstring, callback: PersonalBestCallback) -> i32,
	freeScore:       proc "c" (score: ^PDScore),
	getScoreboards:  proc "c" (callback: BoardsListCallback) -> i32,
	freeBoardsList:  proc "c" (boardsList: ^PDBoardsList),
	getScores:       proc "c" (boardId: cstring, callback: ScoresCallback) -> i32,
	freeScoresList:  proc "c" (scoresList: ^PDScoresList),
}

