#ifndef _QUEUE_HPP_
#define _QUEUE_HPP_

#define QUEUE_WORDS 1024

class hold_queue {
	public:
		hold_queue();
		virtual ~hold_queue() {}
		void set(char c);
		void commit();
		char get();
	private:
		int  rd_ptr;
		int  wr_ptr;
		char hold;
		char buffer[QUEUE_WORDS];
};

#endif

