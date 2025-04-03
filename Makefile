main:
	@swift build
	@cp .build/debug/CLI llama
	@chmod +x llama
	@echo "Run the program with ./llama"
