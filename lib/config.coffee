_     = require 'lodash'
glob  = require 'glob'
fs    = require 'fs'
path  = require 'path'

loadConfig = (configDirPath) ->
  configFilePaths = glob.sync "#{configDirPath}/*.coffee", ignore:["#{configDirPath}/index.coffee"]
  content = {}
  _.each configFilePaths, (configFilePath) ->
    configFileName = path.basename configFilePath, '.coffee'
    configName =  configFileName.replace /(\_\w)/g, (m) -> m[1].toUpperCase()
    content[configName] =  require configFilePath
  content

getImpl = (object, property) ->
  elems = if _.isArray(property) then property else property.split('.')
  name = _.first(elems)
  value = object[name]
  if elems.length <= 1
    return value
  if typeof value isnt 'object'
    return undefined
  getImpl value, elems.slice(1)

# 传入配置文件目录
config = (configDirPath) ->
  error = new Error('No configurations found.')
  return error unless configDirPath
  return error unless _.isString(configDirPath)
  return error unless fs.existsSync(configDirPath)

  # 合并配置内容
  nodeENV = process.env.NODE_ENV or 'development'
  defaultConfigs = loadConfig(configDirPath)
  envConfigs = loadConfig("#{configDirPath}/#{nodeENV}/")
  config.configs = _.defaultsDeep(envConfigs, defaultConfigs)

  # 设置环境变量
  config.configs.env = process.env
  config

config.get = (name) ->
  unless name or _.isString(name)
    return new Error('Calling config.get with null or undefined argument')
  getImpl(config.configs, name)

config.has = (name) ->
  unless name or _.isString(name)
    return new Error('Calling config.has with null or undefined argument')
  getImpl(config.configs, name) isnt undefined

module.exports = config