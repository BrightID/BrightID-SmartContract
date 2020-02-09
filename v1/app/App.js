import React from 'react'
import {
  AragonApp,
  Button,
  Text,
  Field,
  TextInput,
  DropDown,
  Table, TableHeader, TableRow, TableCell,
  AppView,
  BaseStyles,
  AppBar,
  SidePanel
} from '@aragon/ui'
import Aragon, { providers } from '@aragon/client'
import styled from 'styled-components'

function string2hex(tmp) {
  var str = ''
  for(var i = 0; i < tmp.length; i++) {
    str += tmp[i].charCodeAt(0).toString(16)
  }
  return '0x'+str
}

function hex2string(hex) {
  if (!hex) {
    return
  }
  var temp = hex.toString().slice(2)
  var str = ''
  for (var i = 0; (i < temp.length && temp.substr(i, 2) !== '00'); i += 2)
    str += String.fromCharCode(parseInt(temp.substr(i, 2), 16))
  return str
}

export default class App extends React.Component {

  _nodes = {}

  state = {
    isOpenContextForm: false,
    isOpenNodeForm: false,
    activeItem: 0,
    nodes: {},
  }

  handleChange(index) {
    this.setState({ activeItem: index })
  }

  loadAccounts = () => {
    this.props.app.accounts()
        .subscribe(accounts => {
          this.loadNodes(accounts[0])
        })
  }

  componentDidMount() {
    window.addEventListener('load', this.loadAccounts)
  }

  addContext = () => {
    this.props.app.addContext(string2hex(this.state.addContext_contextName))
    this.setState({
      isOpenContextForm: false
    })
  }

  addNodeToContext = () => {
    if (this.state.addNodeToContext_contextName) {
      this.props.app.addNodeToContext(string2hex(this.state.addNodeToContext_contextName), this.state.addNodeToContext_nodeAddress)
    } else {
      this.props.app.addNodeToContext(string2hex(Object.keys(this.state.nodes)[0]), this.state.addNodeToContext_nodeAddress)
    }
    this.setState({
      isOpenNodeForm: false
    })
  }

  removeNodeFromContext = (contextName, nodeAddress) => {
    this.props.app.removeNodeFromContext(string2hex(contextName), nodeAddress)
  }

  addContextForm = () => {

    this.setState({
      addContext_contextName: '',
      isOpenContextForm: true,
    })
  }

  addNodeForm = () => {
    this.setState({
      addNodeToContext_nodeAddress: '',
      isOpenNodeForm: true
    })
  }

  loadNodes = (owner) => {
    var visited = {}
    this.props.app.events()
    .subscribe(event => {
      let name = hex2string(event.returnValues.contextName)
      let address = event.returnValues.nodeAddress
      if (event.event === "LogAddContext" && event.returnValues.owner.toLowerCase() == owner.toLowerCase()) {
        this._nodes[name] = []
        visited[name] = {}
      }
      else if (event.event === "LogAddNodeToContext" && (name in this._nodes) && visited[name][address]!=true) {
        visited[name][address] = true
        this._nodes[name].push(address)
      }
      else if (event.event === "LogRemoveNodeFromContext" && (name in this._nodes) && visited[name][address]==true) {
        visited[name][address] = false
        this._nodes[name].splice(this._nodes[name].indexOf(address), 1)
      }
      this.setState({
        nodes: JSON.parse(JSON.stringify(this._nodes)),
      })
    })
  }

  render () {
    const { isOpenNodeForm, isOpenContextForm, activeItem, nodes } = this.state
    return (
      <AragonApp>
        <BaseStyles />
          <AppBar
            title="BrightID Aragon App"
            endContent={
              <Button mode="strong" onClick={this.addContextForm}>
                Add Context
              </Button>
            }
          >
            <Button mode="strong" onClick={this.addNodeForm}>
              Add Node
            </Button>
          </AppBar>
          <AppView>
            {Object.keys(nodes).map((contextName) => (
              <Table
                header={
                  <TableRow>
                    <TableHeader title={"Context: "+contextName} />
                  </TableRow>
                }
              >
                {
                  nodes[contextName].length == 0
                  ? (
                      <TableRow><TableCell><Text>No nodes</Text></TableCell></TableRow>
                    )
                  : null
                }

                {nodes[contextName].map((nodeAddress) => (
                    <TableRow>
                      <TableCell>
                        <Text>{nodeAddress}</Text>
                      </TableCell>
                      <TableCell>
                        <Button
                          mode="strong"
                          size="small"
                          onClick={evt => this.removeNodeFromContext(contextName, nodeAddress)}
                        >
                          Delete
                        </Button>
                      </TableCell>
                    </TableRow>
                ))}
              </Table>
            ))}
          </AppView>

          <SidePanel
            title="Add Context"
            opened={isOpenContextForm}
            onClose={() => this.setState({isOpenContextForm: false})}
          >
            <Field label="Context">
              <TextInput
                wide
                required
                value={this.state.addContext_contextName}
                onChange={evt => this.setState({addContext_contextName: evt.target.value})}
              />
            </Field>
            <Button mode="strong" wide onClick={this.addContext}>Submit</Button>
          </SidePanel>

          <SidePanel
            title="Add Node To Context"
            opened={isOpenNodeForm}
            onClose={() => this.setState({isOpenNodeForm: false})}
          >
            <Field label="Context">
              <DropDown
                items={Object.keys(nodes)}
                wide
                required
                active={this.state.activeItem}
                onChange={(index, items) => {
                  this.setState({activeItem: index})
                  this.setState({addNodeToContext_contextName: items[index]})
                }}
              />
            </Field>
            <Field label="Node">
              <TextInput
                wide
                placeholder="Node's Ethereum Address"
                value={this.state.addNodeToContext_nodeAddress}
                required
                onChange={evt => this.setState({addNodeToContext_nodeAddress: evt.target.value})}
              />
            </Field>
            <Button mode="strong" wide onClick={this.addNodeToContext}>Submit</Button>
          </SidePanel>
      </AragonApp>
    )
  }
}

