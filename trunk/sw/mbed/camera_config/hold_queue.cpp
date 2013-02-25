#include "hold_queue.hpp"

// constructor
hold_queue::hold_queue() {
	rd_ptr = 0;
	wr_ptr = 0;
	hold   = 0x0;
}

void hold_queue::set(char c) {
	hold = c;
	return;
}

void hold_queue::commit() {
	if(wr_ptr == QUEUE_WORDS) {
		// fifo overflow
		return;
	}
	buffer[wr_ptr++] = hold;
	return;
}

char hold_queue::get() {
	if(rd_ptr == wr_ptr) {
		// fifo underflow
		return 0x0;
	}
	return buffer[rd_ptr++];
}

