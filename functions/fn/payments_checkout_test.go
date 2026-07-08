package fn

import (
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"testing"
)

func TestBuildWompiCheckoutURL_SinSecretoNoFirma(t *testing.T) {
	req := CreatePaymentRequest{
		Reference: "order_abc123",
		Amount:    50000,
		Currency:  "COP",
	}
	u := buildWompiCheckoutURL("pub_test_x", req, "")

	if strings.Contains(u, "signature:integrity") {
		t.Errorf("no debería incluir firma sin secreto: %s", u)
	}
	if !strings.Contains(u, "amount-in-cents=5000000") {
		t.Errorf("monto en centavos incorrecto: %s", u)
	}
	if !strings.Contains(u, "reference=order_abc123") {
		t.Errorf("referencia ausente: %s", u)
	}
}

func TestBuildWompiCheckoutURL_ConSecretoAgregaFirma(t *testing.T) {
	req := CreatePaymentRequest{
		Reference: "order_abc123",
		Amount:    50000,
		Currency:  "COP",
	}
	secret := "test_integrity_secret"
	u := buildWompiCheckoutURL("pub_test_x", req, secret)

	// Wompi: SHA256(reference + amount_in_cents + currency + secreto)
	raw := "order_abc123" + "5000000" + "COP" + secret
	sum := sha256.Sum256([]byte(raw))
	expected := "signature:integrity=" + hex.EncodeToString(sum[:])

	if !strings.Contains(u, expected) {
		t.Errorf("firma de integridad incorrecta.\nurl: %s\nesperado contener: %s", u, expected)
	}
}
