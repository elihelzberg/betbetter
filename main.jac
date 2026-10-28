"""Jac entry point: typed server RPC plus the browser dashboard."""
import from endpoints { list_games, game_history, ask_question }
import from mobile_api { mobile_games, mobile_game_history, mobile_ask }
import from .frontend { Dashboard }

def:pub app -> JsxElement { return <Dashboard/>; }
