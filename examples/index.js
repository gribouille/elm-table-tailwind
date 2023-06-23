
import { Elm as AppDynamic } from "./src/Dynamic.elm"
import { Elm as AppDynamicProgressive } from "./src/DynamicProgressive.elm"
import { Elm as AppStatic } from "./src/Static.elm"
import { Elm as AppStaticProgressive } from "./src/StaticProgressive.elm"
import { Elm as AppSubtable } from "./src/Subtable.elm"

const x = await import("./src/DynamicSubtable.elm")
console.log(x)
x.Elm['DynamicSubtable'].init({ node: document.getElementById('dynamic_subtable') })

AppStatic.Static.init({ node: document.getElementById('static') })
AppDynamic.Dynamic.init({ node: document.getElementById('dynamic') })
AppSubtable.Subtable.init({ node: document.getElementById('subtable') })
AppStaticProgressive.StaticProgressive.init({ node: document.getElementById('static_progressive') })
AppDynamicProgressive.DynamicProgressive.init({ node: document.getElementById('dynamic_progressive') })
