<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Registrar Entrada no Caixa</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
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
            border-top: 3px solid var(--success-color);
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
        
        input[type="text"], 
        input[type="number"], 
        textarea, 
        select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: var(--border-radius);
            font-family: 'Roboto', sans-serif;
            font-size: 0.95rem;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        
        input[type="text"]:focus, 
        input[type="number"]:focus, 
        textarea:focus, 
        select:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 2px rgba(67, 97, 238, 0.2);
        }
        
        button {
            background-color: var(--success-color);
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
            background-color: #3ab4d8;
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
        
        @media (max-width: 768px) {
            .container {
                padding: 15px;
                max-width: 100%;
            }
            
            .card {
                padding: 20px;
            }
            
            .navigation-links {
                flex-direction: column;
                gap: 8px;
            }
            
            h1 {
                font-size: 1.3rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1><i class="fas fa-hand-holding-usd"></i> Registrar Entrada</h1>
            
            <%
            // Verificar se há caixa aberto
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            boolean caixaAberto = false;
            int idCaixaAberto = -1;
            
            try {
                Class.forName("org.mariadb.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
                stmt = conn.prepareStatement("SELECT id_caixa FROM caixa WHERE status = 'aberto' LIMIT 1");
                rs = stmt.executeQuery();
                if(rs.next()) {
                    caixaAberto = true;
                    idCaixaAberto = rs.getInt(1);
                }
            } catch(Exception e) {
                e.printStackTrace();
            } finally {
                if(rs != null) rs.close();
                if(stmt != null) stmt.close();
                if(conn != null) conn.close();
            }
            
            if(!caixaAberto) {
            %>
                <div class="mensagem erro">
                    <i class="fas fa-exclamation-circle"></i> Não há caixa aberto. <a href="abrir_caixa.jsp">Abrir caixa</a> antes de registrar entradas.
                </div>
            <%
            } else {
            %>
            
            <form action="processar_entrada.jsp" method="post">
                <input type="hidden" name="id_caixa" value="<%= idCaixaAberto %>">
                
                <div class="form-group input-icon">
                    <i class="fas fa-file-alt"></i>
                    <label for="descricao">Descrição</label>
                    <input type="text" id="descricao" name="descricao" placeholder="Ex: Pagamento pedido #123" required>
                </div>
                
                <div class="form-group input-icon">
                    <i class="fas fa-money-bill-wave"></i>
                    <label for="valor">Valor</label>
                    <input type="number" id="valor" name="valor" step="0.01" min="0.01" 
                           placeholder="0,00" required>
                </div>
                
                <div class="form-group input-icon">
                    <i class="fas fa-credit-card"></i>
                    <label for="forma_pagamento">Forma de Pagamento</label>
                    <select id="forma_pagamento" name="forma_pagamento" required>
                        <option value="dinheiro">Dinheiro</option>
                        <option value="cartao">Cartão</option>
                        <option value="transferencia">Transferência</option>
                        <option value="outro">Outro</option>
                    </select>
                </div>
                
                <div class="form-group input-icon">
                    <i class="fas fa-box-open"></i>
                    <label for="nr_pedido">Nº Pedido (opcional)</label>
                    <input type="text" id="nr_pedido" name="nr_pedido" placeholder="Ex: 12345">
                </div>
                
                <button type="submit">
                    <i class="fas fa-check-circle"></i> Registrar
                </button>
            </form>
            <%
            }
            %>
            
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
                <a href="listar_caixa.jsp"><i class="fas fa-list-alt"></i> Movimentações</a>
                <a href="caixa.jsp"><i class="fas fa-home"></i> Início</a>
            </div>
        </div>
    </div>
</body>
</html>