
import { Elm as AppDynamic } from "./src/Dynamic.elm"
import { Elm as AppStatic } from "./src/Static.elm"
import { Elm as AppSubtable } from "./src/Subtable.elm"

AppStatic.Static.init({ node: document.getElementById('static') })
AppDynamic.Dynamic.init({ node: document.getElementById('dynamic') })
AppSubtable.Subtable.init({ node: document.getElementById('subtable') })
