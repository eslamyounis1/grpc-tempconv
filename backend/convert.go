package main

import (
	"errors"
	"fmt"
	"strings"
)

const (
	unitC = "C"
	unitF = "F"
)

func convertTemp(value float64, from, to string) (float64, error) {
	from = strings.ToUpper(strings.TrimSpace(from))
	to = strings.ToUpper(strings.TrimSpace(to))

	if from == "" || to == "" {
		return 0, errors.New("from and to units are required")
	}
	if from != unitC && from != unitF {
		return 0, fmt.Errorf("unsupported from unit: %s", from)
	}
	if to != unitC && to != unitF {
		return 0, fmt.Errorf("unsupported to unit: %s", to)
	}
	if from == to {
		return 0, errors.New("from and to units must be different")
	}

	switch {
	case from == unitC && to == unitF:
		return (value*9.0/5.0 + 32.0), nil
	case from == unitF && to == unitC:
		return ((value - 32.0) * 5.0 / 9.0), nil
	default:
		return 0, errors.New("unsupported conversion")
	}
}
