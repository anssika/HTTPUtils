Class HTTPUtils.TestProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HTTPUtils.TestProduction" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="HTTPServiceAdapter" Category="" ClassName="HTTPUtils.Service.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">51000</Setting>
  </Item>
  <Item Name="To_HTTPServiceAdapter" Category="" ClassName="HTTPUtils.Operation.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">51000</Setting>
    <Setting Target="Adapter" Name="HTTPServer">localhost</Setting>
    <Setting Target="Adapter" Name="URL">/HTTPUtils</Setting>
    <Setting Target="Adapter" Name="ProxyPort">8080</Setting>
    <Setting Target="Adapter" Name="ProxyServer"></Setting>
    <Setting Target="Host" Name="RetryInterval">20</Setting>
    <Setting Target="Adapter" Name="ResponseTimeout">10</Setting>
  </Item>
  <Item Name="To_WebGateway" Category="" ClassName="HTTPUtils.Operation.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">52775</Setting>
    <Setting Target="Adapter" Name="HTTPServer">localhost</Setting>
    <Setting Target="Adapter" Name="URL">/HTTPUtils</Setting>
    <Setting Target="Adapter" Name="ProxyPort">8080</Setting>
    <Setting Target="Host" Name="RetryInterval">20</Setting>
    <Setting Target="Adapter" Name="ResponseTimeout">10</Setting>
  </Item>
  <Item Name="To_LocalFHIRToLabEx" Category="" ClassName="HTTPUtils.Operation.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">52779</Setting>
    <Setting Target="Adapter" Name="HTTPServer">localhost</Setting>
    <Setting Target="Host" Name="FailureTimeout">5</Setting>
  </Item>
  <Item Name="To_sfs01" Category="" ClassName="HTTPUtils.Operation.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials">sfs01</Setting>
    <Setting Target="Adapter" Name="HTTPServer">fi01.intersystems.co.uk</Setting>
    <Setting Target="Adapter" Name="SSLConfig">CGI</Setting>
    <Setting Target="Host" Name="FailureTimeout">20</Setting>
  </Item>
  <Item Name="To_CGI" Category="" ClassName="HTTPUtils.Operation.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">40124</Setting>
    <Setting Target="Adapter" Name="HTTPServer">20.101.180.117</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
    <Setting Target="Adapter" Name="SSLConfig">CGI</Setting>
    <Setting Target="Host" Name="FailureTimeout">20</Setting>
  </Item>
</Production>
}

}
