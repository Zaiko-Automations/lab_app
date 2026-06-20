#!/bin/bash
# send_test_payload.sh
# Simula o envio de payload do n8n/Lucas para a API Rails

# Configuraçoes
API_URL="${API_URL:-http://localhost:3000/api/v1/webhooks}"
API_TOKEN="${API_TOKEN:-vida_lucas_secret_token_2026}"

# Gera uma imagem base64 simples (1x1 pixel JPEG para teste)
TINY_JPEG="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/xAAUAQEAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8AJQAB/9k="

echo "📤 Enviando payload de teste para: $API_URL"
echo "🔑 Token: $API_TOKEN"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "X-API-Token: $API_TOKEN" \
  -d "{
  \"conversa_id\": \"TEST-$(date +%s)\",
  \"link_conversa\": \"https://parceiro.com.br/conversa/test\",
  \"tipo\": \"orcamento\",
  \"paciente\": {
    \"nome\": \"Maria da Silva Teste\",
    \"cpf\": \"71428793860\",
    \"data_nascimento\": \"1985-03-10\",
    \"telefone\": \"73999998888\",
    \"whatsapp\": true,
    \"id_whatsapp\": \"5573999998888\",
    \"convenio\": \"particular\",
    \"plano_convenio\": \"Geral\",
    \"sexo_biologico\": \"F\",
    \"logradouro\": \"Rua Principal\",
    \"numero\": \"100\",
    \"cep\": \"45600000\",
    \"bairro\": \"Centro\",
    \"complemento\": \"Apto 202\",
    \"cidade\": \"Itabuna\",
    \"uf\": \"BA\",
    \"numero_carteira\": \"1234567891000\",
    \"data_validade_carteira\": \"2026-06-30\",
    \"data_pedido_medico\": \"2026-06-15\"
  },
  \"solicitante\": {
    \"nome\": \"Dr. Carlos Médico\",
    \"numero_conselho\": \"CRM-BA-12345\"
  },
  \"exames_solicitados\": [
    { \"codigo\": \"HEM\", \"descricao\": \"Hemograma Completo\" },
    { \"codigo\": \"GLI\", \"descricao\": \"Glicose\" },
    { \"codigo\": \"CREAT\", \"descricao\": \"Creatinina\" }
  ],
  \"imagens\": {
    \"documento\": \"$TINY_JPEG\",
    \"pedido_medico\": \"$TINY_JPEG\",
    \"carteira_convenio\": \"$TINY_JPEG\"
  }
}")

# Separa o body da resposta e o HTTP status code
HTTP_BODY=$(echo "$RESPONSE" | head -n 1)
HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

echo "📩 Status HTTP: $HTTP_STATUS"
echo "📋 Resposta:"
echo "$HTTP_BODY" | python3 -m json.tool 2>/dev/null || echo "$HTTP_BODY"

if [ "$HTTP_STATUS" -eq 202 ]; then
  echo ""
  echo "✅ Sucesso! Payload recebido e enfileirado para processamento."
  echo "   Aguarde alguns segundos e acesse http://localhost:3000 para ver o pedido na fila."
else
  echo ""
  echo "❌ Falhou com status $HTTP_STATUS"
fi
