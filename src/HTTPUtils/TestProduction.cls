Class HTTPUtils.TestProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HTTPUtils.TestProduction" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="HTTPService_AdapterInspect" Category="" ClassName="HTTPUtils.Service.HTTPInspect" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">51000</Setting>
  </Item>
  <Item Name="To_HTTPService_AdapterInspect" Category="" ClassName="HTTPUtils.Operation.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
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
    <Setting Target="Adapter" Name="HTTPPort">52773</Setting>
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
  <Item Name="Update" Category="ex04.04,ex04.04all" ClassName="HTTPUtils.Training.Process.Update" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="To_SourceSystem" Category="ex04.04,ex04.04all" ClassName="HTTPUtils.Operation.HTTPJSON" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">51101</Setting>
    <Setting Target="Adapter" Name="HTTPServer">localhost</Setting>
    <Setting Target="Adapter" Name="URL">/SourceSystem/API</Setting>
    <Setting Target="Host" Name="RetryInterval">20</Setting>
    <Setting Target="Adapter" Name="ResponseTimeout">10</Setting>
    <Setting Target="Adapter" Name="WriteLog">1</Setting>
  </Item>
  <Item Name="To_TargetSystem" Category="ex04.04,ex04.04all" ClassName="HTTPUtils.Operation.HTTPJSON" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">51102</Setting>
    <Setting Target="Adapter" Name="HTTPServer">localhost</Setting>
    <Setting Target="Adapter" Name="URL">/TargetSystem/API</Setting>
    <Setting Target="Host" Name="RetryInterval">20</Setting>
    <Setting Target="Adapter" Name="ResponseTimeout">10</Setting>
  </Item>
  <Item Name="APIOfSourceSystem" Category="ex04.04all,ex04.04testEnv" ClassName="HTTPUtils.Service.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">51101</Setting>
    <Setting Target="Host" Name="TargetConfigName">SourceSystem</Setting>
    <Setting Target="Adapter" Name="Log">1</Setting>
    <Setting Target="Adapter" Name="WriteLog">1</Setting>
  </Item>
  <Item Name="APIOfTargetSystem" Category="ex04.04all,ex04.04testEnv" ClassName="HTTPUtils.Service.HTTP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">51102</Setting>
    <Setting Target="Host" Name="TargetConfigName">TargetSystem</Setting>
  </Item>
  <Item Name="SourceSystem" Category="ex04.04all,ex04.04testEnv" ClassName="HTTPUtils.Training.Process.SourceSystem" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Updates">some updates</Setting>
  </Item>
  <Item Name="TargetSystem" Category="ex04.04all,ex04.04testEnv" ClassName="HTTPUtils.Process.Simple" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
