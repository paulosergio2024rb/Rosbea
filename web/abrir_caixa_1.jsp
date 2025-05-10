<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Abrir Caixa</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Mantenha o mesmo estilo da sua página de entrada/saída */
        :root {
            --primary-color: #4361ee;
            --success-color: #4cc9f0;
            --danger-color: #f72585;
            --light-color: #f8f9fa;
            --dark-color: #212529;
            --border-radius: 6px;
            --box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f7fa;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 500px;
            margin: 30px auto;
            padding: 20px;
        }
        
        .card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--box-shadow);
            border-top: 3px solid var(--primary-color);
        }
        
        h1 {
            color: var(--dark-color);
            text-align: center;
            margin-bottom: 20px;
            font-weight: 500;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        .form-group {
            margin-bottom: 16px;
        }
        
        label {
            display: block;
            margin-bottom: 6px;
            font-weight: 500;
            color: #555;
            font-size: 0.9rem;
        }
        
        input[type="number"] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: var(--border-radius);
            font-family: 'Roboto', sans-serif;
            font-size: 0.95rem;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        
        input[type="number"]:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 2px rgba(67, 97, 238, 0.2);
        }
        
        button {
            background-color: var(--primary-color);
            color: white;
            padding: 10px 16px;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-size: 0.95rem;
            font-weight: 500;
            width: 100%;
            transition: background-color 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 10px;
        }
        
        button:hover {
            background-color: #3a56d4;
        }
        
        .mensagem {
            padding: 12px;
            margin: 15px 0;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.9rem;
        }
        
        .sucesso {
            background-color: #e6f7ee;
            color: #0a8f4e;
            border-left: 3px solid #0a8f4e;
        }
        
        .erro {
            background-color: #feecef;
            color: #d91a4d;
            border-left: 3px solid #d91a4d;
        }
        
        .navigation-links {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
            gap: 10px;
        }
        
        .navigation-links a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
            padding: 8px 12px;
            border-radius: var(--border-radius);
            transition: background-color 0.3s;
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.85rem;
            flex: 1;
            justify-content: center;
            text-align: center;
        }
        
        .navigation-links a:hover {
            background-color: #f0f2ff;
        }
        
        .input-icon {
            position: relative;
        }
        
        .input-icon i {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
            font-size: 0.9rem;
        }
        
        .input-icon input {
            padding-left: 32px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1><i class="fas fa-cash-register"></i> Abrir Caixa</h1>
            
            <form action="processar_abertura.jsp" method="post">
                <div class="form-group input-icon">
                    <i class="fas fa-money-bill-wave"></i>
                    <label for="valor_inicial">Valor Inicial (R$) *</label>
                    <input type="number" id="valor_inicial" name="valor_inicial" 
                           step="0.01" min="0" placeholder="0,00" required>
                </div>
                
                <button type="submit">
                    <i class="fas fa-lock-open"></i> Abrir Caixa
                </button>
            </form>
            
            <%
            String mensagem = (String) request.getAttribute("mensagem");
            String tipoMensagem = (String) request.getAttribute("tipoMensagem");
            
            if (mensagem != null) {
            %>
                <div class="mensagem <%= tipoMensagem %>">
                    <i class="fas <%= tipoMensagem.equals("sucesso") ? "fa-check-circle" : "fa-exclamation-circle" %>"></i>
                    <%= mensagem %>
                </div>
            <%
            }
            %>
            
            <div class="navigation-links">
                <a href="caixa.jsp"><i class="fas fa-home"></i> Voltar ao Início</a>
            </div>
        </div>
    </div>
</body>
</html>