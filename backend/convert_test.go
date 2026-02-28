package main

import (
	"context"
	"testing"

	pb "tempconv-backend/pb"
)

func TestConvertTemp(t *testing.T) {
	tests := []struct {
		name      string
		value     float64
		from      string
		to        string
		want      float64
		wantError bool
	}{
		{name: "c to f", value: 0, from: "C", to: "F", want: 32},
		{name: "f to c", value: 32, from: "F", to: "C", want: 0},
		{name: "negative", value: -40, from: "C", to: "F", want: -40},
		{name: "invalid unit", value: 10, from: "K", to: "C", wantError: true},
		{name: "same unit", value: 10, from: "C", to: "C", wantError: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := convertTemp(tt.value, tt.from, tt.to)
			if (err != nil) != tt.wantError {
				t.Fatalf("error = %v, wantError %v", err, tt.wantError)
			}
			if !tt.wantError && got != tt.want {
				t.Fatalf("got %v, want %v", got, tt.want)
			}
		})
	}
}

func TestConverterServerConvert(t *testing.T) {
	srv := &converterServer{}
	resp, err := srv.Convert(context.Background(), &pb.ConvertRequest{
		Value: 100,
		From:  "C",
		To:    "F",
	})
	if err != nil {
		t.Fatalf("Convert returned error: %v", err)
	}
	if resp.GetResult() != 212 {
		t.Fatalf("got %v, want 212", resp.GetResult())
	}
}
