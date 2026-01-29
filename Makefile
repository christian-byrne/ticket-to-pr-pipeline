.PHONY: setup status clean

setup:
	@./setup.sh

status:
	@echo "Run: amp /skill pipeline-tracker"
	@echo "Then use: status [RUN_ID]"

clean:
	@rm -rf runs/*
	@echo "Cleaned runs/"
