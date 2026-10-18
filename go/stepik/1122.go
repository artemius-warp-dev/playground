package main

import "fmt"

func main() {
	// здесь должен быть ваш код

	var n int

	fmt.Scan(&n) // число

	items := make([]int, n)
	for i := range items {
		fmt.Scan(&items[i])
	}
	fmt.Println(items[3])
}
