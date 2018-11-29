import React from 'react'
import {
  AragonApp,
  Button,
  Text,
  Field,
  TextInput,
  Table, TableHeader, TableRow, TableCell,
  AppView, BaseStyles, PublicUrl, AppBar,
  SidePanel,
  observe
} from '@aragon/ui'
import Aragon, { providers } from '@aragon/client'
import styled from 'styled-components'

const AppContainer = styled(AragonApp)`
  display: flex;
  align-items: center;
  justify-content: center;
`

function string2hex(tmp) {
  var str = '';
  for(var i = 0; i < tmp.length; i++) {
    str += tmp[i].charCodeAt(0).toString(16);
  }
  return '0x'+str;
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
    message: '',
    nodes: {},
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
    this.props.app.addNodeToContext(string2hex(this.state.addNodeToContext_contextName), this.state.addNodeToContext_nodeAddress);
    this.setState({
      isOpenNodeForm: false
    })
  }

  removeNodeFromContext = (contextName, nodeAddress) => {
    this.props.app.removeNodeFromContext(string2hex(contextName), nodeAddress)
  }

  addContextForm = () => {
    this.setState({
      isOpenContextForm: true,
    })
  }

  addNodeForm = () => {
    this.setState({
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
      }
      else if (event.event === "LogAddNodeToContext" && (name in this._nodes) && !(address in visited)) {
        visited[address] = true
        this._nodes[name].push(address)
      }
      else if (event.event === "LogRemoveNodeFromContext" && (name in this._nodes) && (address in visited)) {
        visited[address] = false
        this._nodes[name].splice(this._nodes[name].indexOf(address), 1);
      }
      this.setState({
        nodes: JSON.parse(JSON.stringify(this._nodes)),
      })
    })
  }

  render () {
    const { isOpenNodeForm, isOpenContextForm, message, nodes } = this.state
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
              <TextInput
                wide
                onChange={evt => this.setState({addNodeToContext_contextName: evt.target.value})}
              />
            </Field>
            <Field label="Node">
              <TextInput
                wide
                onChange={evt => this.setState({addNodeToContext_nodeAddress: evt.target.value})}
              />
            </Field>
            <Button mode="strong" wide onClick={this.addNodeToContext}>Submit</Button>
          </SidePanel>
      </AragonApp>
    )
  }
}

