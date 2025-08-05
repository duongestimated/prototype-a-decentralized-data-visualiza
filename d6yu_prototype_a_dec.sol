pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/access/Roles.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract d6yuPrototypeADec {
    using Roles for address[];
    using SafeMath for uint256;

    // Mapping of data sources to their corresponding visualization integrators
    mapping (address => mapping (address => VisualizationIntegrator)) public dataSources;

    // Event emitted when a new data source is added
    event NewDataSource(address indexed dataSource, address visualizationIntegrator);

    // Event emitted when a data source is updated
    event UpdateDataSource(address indexed dataSource, address visualizationIntegrator);

    // Event emitted when a data source is removed
    event RemoveDataSource(address indexed dataSource);

    // Mapping of visualization integrators to their corresponding data sources
    mapping (address => address[]) public visualizationIntegrators;

    // Event emitted when a new visualization integrator is added
    event NewVisualizationIntegrator(address indexed visualizationIntegrator, address[] dataSources);

    // Event emitted when a visualization integrator is updated
    event UpdateVisualizationIntegrator(address indexed visualizationIntegrator, address[] dataSources);

    // Event emitted when a visualization integrator is removed
    event RemoveVisualizationIntegrator(address indexed visualizationIntegrator);

    // Struct representing a visualization integrator
    struct VisualizationIntegrator {
        address dataSource;
        bytes32 visualizationType;
        bytes visualizationData;
    }

    // Modifier to check if the caller is the owner of the contract
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Owner of the contract
    address public owner;

    // Constructor function
    constructor() public {
        owner = msg.sender;
    }

    // Function to add a new data source
    function addDataSource(address _dataSource, bytes32 _visualizationType, bytes _visualizationData) public {
        require(_dataSource != address(0), "Data source cannot be zero address");
        require(_visualizationType != bytes32(0), "Visualization type cannot be zero bytes32");
        require(_visualizationData.length > 0, "Visualization data cannot be empty");

        VisualizationIntegrator memory integrator = VisualizationIntegrator(_dataSource, _visualizationType, _visualizationData);
        dataSources[_dataSource][_dataSource] = integrator;
        visualizationIntegrators[_dataSource].push(_dataSource);

        emit NewDataSource(_dataSource, _dataSource);
    }

    // Function to update a data source
    function updateDataSource(address _dataSource, bytes32 _visualizationType, bytes _visualizationData) public {
        require(_dataSource != address(0), "Data source cannot be zero address");
        require(_visualizationType != bytes32(0), "Visualization type cannot be zero bytes32");
        require(_visualizationData.length > 0, "Visualization data cannot be empty");
        require(dataSources[_dataSource][_dataSource].dataSource != address(0), "Data source does not exist");

        VisualizationIntegrator storage integrator = dataSources[_dataSource][_dataSource];
        integrator.visualizationType = _visualizationType;
        integrator.visualizationData = _visualizationData;

        emit UpdateDataSource(_dataSource, _dataSource);
    }

    // Function to remove a data source
    function removeDataSource(address _dataSource) public onlyOwner {
        require(_dataSource != address(0), "Data source cannot be zero address");
        require(dataSources[_dataSource][_dataSource].dataSource != address(0), "Data source does not exist");

        delete dataSources[_dataSource][_dataSource];
        delete visualizationIntegrators[_dataSource];

        emit RemoveDataSource(_dataSource);
    }

    // Function to add a new visualization integrator
    function addVisualizationIntegrator(address _visualizationIntegrator, address[] _dataSources) public onlyOwner {
        require(_visualizationIntegrator != address(0), "Visualization integrator cannot be zero address");
        require(_dataSources.length > 0, "Data sources cannot be empty");

        visualizationIntegrators[_visualizationIntegrator] = _dataSources;

        for (uint256 i = 0; i < _dataSources.length; i++) {
            dataSources[_dataSources[i]][_visualizationIntegrator] = VisualizationIntegrator(_dataSources[i], bytes32(0), bytes(""));
        }

        emit NewVisualizationIntegrator(_visualizationIntegrator, _dataSources);
    }

    // Function to update a visualization integrator
    function updateVisualizationIntegrator(address _visualizationIntegrator, address[] _dataSources) public onlyOwner {
        require(_visualizationIntegrator != address(0), "Visualization integrator cannot be zero address");
        require(_dataSources.length > 0, "Data sources cannot be empty");
        require(visualizationIntegrators[_visualizationIntegrator].length > 0, "Visualization integrator does not exist");

        visualizationIntegrators[_visualizationIntegrator] = _dataSources;

        for (uint256 i = 0; i < _dataSources.length; i++) {
            dataSources[_dataSources[i]][_visualizationIntegrator] = VisualizationIntegrator(_dataSources[i], bytes32(0), bytes(""));
        }

        emit UpdateVisualizationIntegrator(_visualizationIntegrator, _dataSources);
    }

    // Function to remove a visualization integrator
    function removeVisualizationIntegrator(address _visualizationIntegrator) public onlyOwner {
        require(_visualizationIntegrator != address(0), "Visualization integrator cannot be zero address");
        require(visualizationIntegrators[_visualizationIntegrator].length > 0, "Visualization integrator does not exist");

        delete visualizationIntegrators[_visualizationIntegrator];

        for (uint256 i = 0; i < visualizationIntegrators[_visualizationIntegrator].length; i++) {
            delete dataSources[visualizationIntegrators[_visualizationIntegrator][i]][_visualizationIntegrator];
        }

        emit RemoveVisualizationIntegrator(_visualizationIntegrator);
    }
}