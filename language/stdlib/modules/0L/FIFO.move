address 0x1 {

//Implementation of a FIFO that utilizes two vectors
//Achieves Amortized O(1) cost per operation 
//CAUTION: In worst case this can result in O(n) cost, adjust gas allowance accordingly 
module FIFO {
    use 0x1::Vector;


    struct FIFO<Element> {
        incoming: vector<Element>,
        outgoing: vector<Element>
    }
    public fun empty<Element>(): FIFO<Element>{
        let incoming = Vector::empty<Element>();
        let outgoing = Vector::empty<Element>();
        FIFO {
            incoming:incoming,
            outgoing:outgoing,
        }
    }

    public fun push<Element>(v: &mut FIFO<Element>, new_item: Element){
        Vector::push_back<Element>(&mut v.incoming, new_item);
    }

    public fun push_LIFO<Element>(v: &mut FIFO<Element>, new_item: Element){
        Vector::push_back<Element>(&mut v.outgoing, new_item);
    }

    public fun pop<Element>(v: &mut FIFO<Element>): Element{
        perform_swap<Element>(v);
        //now pop from the outgoing queue
        Vector::pop_back<Element>(&mut v.outgoing)
    }

    public fun peek<Element>(v: &mut FIFO<Element>): & Element{
        perform_swap<Element>(v);

        let len = Vector::length<Element>(& v.outgoing);
        Vector::borrow<Element>(& v.outgoing, len - 1)
    }

    public fun peek_mut<Element>(v: &mut FIFO<Element>): &mut Element{
        perform_swap<Element>(v);

        let len = Vector::length<Element>(& v.outgoing);
        Vector::borrow_mut<Element>(&mut v.outgoing, len - 1)
    }

    public fun len<Element>(v: & FIFO<Element>): u64{
        Vector::length<Element>(& v.outgoing) + Vector::length<Element>(& v.incoming)
    }

    //this function does not index the elements in any particular order
    //as such it should only be used for searching through the whole FIFO
    public fun borrow<Element>(v: &FIFO<Element>, i: u64): &Element {
        //if i is out of bounds that will be caught by the underlying vector module
        let len = Vector::length<Element>(&v.incoming);
        if (i < len) {
            Vector::borrow<Element>(&v.incoming, i)
        }
        else {
            Vector::borrow<Element>(&v.outgoing, i - len)
        }
    }

    public fun borrow_mut<Element>(v: &mut FIFO<Element>, i: u64): &mut Element {
        //if i is out of bounds that will be caught by the underlying vector module
        let len = Vector::length<Element>(&v.incoming);
        if (i < len) {
            Vector::borrow_mut<Element>(&mut v.incoming, i)
        }
        else {
            Vector::borrow_mut<Element>(&mut v.outgoing, i - len)
        }
    }

    fun perform_swap<Element>(v: &mut FIFO<Element>) {
        if (Vector::length<Element>(& v.outgoing) == 0) {
            //TODO: Add a proper error here, can't pop from an empty FIFO
            let len = Vector::length<Element>(&v.incoming);
            assert(len > 0, 1);
            //If outgoing is empty, pop all of incoming into outgoing
            while (len > 0) {
                Vector::push_back<Element>(&mut v.outgoing, 
                    Vector::pop_back<Element>(&mut v.incoming));
                len = len - 1;
            }
        };
    }

}






}