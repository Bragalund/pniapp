.PHONY: test shellcheck

test:
	bash test_notes.sh

shellcheck:
	shellcheck openNotes.sh closeNotes.sh test_notes.sh
