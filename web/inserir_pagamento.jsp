<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Inserir Pagamento</title>
</head>
<body>
    <h1>Inserir Valor de Pagamento</h1>

    <form action="processar_pagamento.jsp" method="post">
        <div>
            <label for="id_vencimento">ID do Vencimento:</label>
            <input type="number" id="id_vencimento" name="id_vencimento" required>
        </div>
        <br>
        <div>
            <label for="valor_pago">Valor Pago:</label>
            <input type="number" id="valor_pago" name="valor_pago" step="0.01" required>
        </div>
        <br>
        <button type="submit">Salvar Pagamento</button>
    </form>

</body>
</html>