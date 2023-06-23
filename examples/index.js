const examples = [
  { name: 'Static', node: 'static' },
  { name: 'Dynamic', node: 'dynamic' },
  { name: 'Subtable', node: 'subtable' },
  { name: 'DynamicProgressive', node: 'dynamic_progressive' },
  { name: 'StaticProgressive', node: 'static_progressive' },
  { name: 'DynamicSubtable', node: 'dynamic_subtable' }
]

examples.forEach(async ({ name, node }) => {
  const mod = await import(`./src/${name}.elm`)
  mod.Elm[name].init({ node: document.getElementById(node) })
})