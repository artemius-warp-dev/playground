package broker

import "sync"

type Message struct {
	Topic string
	Payload interface{}
}

//Custom error

type Broker struct {
	subscribers map[string][]func(msg Message)
	mu sync.RWMutex
	
}


func NewBroker() *Broker {
	return &Broker{
		subscribers: make(map[string][]func(msg Message)),
	}
}

func (b *Broker) Publish(topic string, msg Message) {
	b.mu.RLock()
	defer b.mu.RUnlock()
	if handlers, ok := b.subscribers[topic]; ok {
		for _, handler := range handlers {
			go handler(msg)
		}
	}
}

func (b *Broker) Subscribe(topic string, handler func(msg Message)) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.subscribers[topic] = append(b.subscribers[topic], handler)
}


//func (b *Broker) Unsubscribe(topic string, ch
