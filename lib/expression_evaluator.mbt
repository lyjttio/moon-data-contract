// MoonBit Data Contract - Business Rule Expression Evaluator

///|
pub(all) enum TokenType {
  TokIdent(String)
  TokString(String)
  TokNumber(Double)
  TokOp(String)
  TokEOF
} derive(Debug, Eq)

///|
pub(all) struct ExpressionRule {
  rule_id : String
  expression : String
  error_message : String
} derive(Debug, Eq)

///|
pub fn ExpressionRule::new(
  rule_id : String,
  expression : String,
  error_message : String,
) -> ExpressionRule {
  { rule_id, expression, error_message }
}

///|
pub fn tokenize_expression(expr : String) -> Array[TokenType] {
  let tokens : Array[TokenType] = []
  let mut start_idx = 0

  for i = 0; i < expr.length(); i = i + 1 {
    let ch = expr[i]
    if ch == ' ' || ch == '(' || ch == ')' {
      if i > start_idx {
        let token_str = expr[start_idx:i].to_owned()
        if token_str == "AND" ||
          token_str == "OR" ||
          token_str == "==" ||
          token_str == "!=" ||
          token_str == ">" ||
          token_str == "<" {
          tokens.push(TokOp(token_str))
        } else {
          tokens.push(TokIdent(token_str))
        }
      }
      start_idx = i + 1
    }
  }

  if expr.length() > start_idx {
    let token_str = expr[start_idx:expr.length()].to_owned()
    if token_str.length() > 0 {
      tokens.push(TokIdent(token_str))
    }
  }

  tokens.push(TokEOF)
  tokens
}

///|
pub fn evaluate_expression_rule(
  rule : ExpressionRule,
  payload : Map[String, FieldValue],
) -> Array[ValidationError] {
  let violations : Array[ValidationError] = []
  let tokens = tokenize_expression(rule.expression)

  if tokens.length() > 0 {
    let first_token = tokens[0]
    match first_token {
      TokIdent(var_name) => {
        let val_opt = payload.get(var_name)
        if val_opt is None {
          violations.push({
            field: var_name,
            message: rule.error_message +
            " (Variable '" +
            var_name +
            "' is null or missing)",
            code: "EXPRESSION_EVAL_FAILED",
          })
        }
      }
      _ => ()
    }
  }

  violations
}
