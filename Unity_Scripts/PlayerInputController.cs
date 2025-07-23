using UnityEngine;

public class PlayerInputController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float moveSpeed = 5f;
    public float smoothTime = 0.1f;
    
    [Header("Input Settings")]
    public KeyCode forwardKey = KeyCode.W;
    public KeyCode backwardKey = KeyCode.S;
    public KeyCode leftKey = KeyCode.A;
    public KeyCode rightKey = KeyCode.D;
    
    private GameNetworkManager networkManager;
    private Vector3 targetPosition;
    private Vector3 velocity;
    private Vector3 lastSentPosition;
    private float positionSendThreshold = 0.1f; // Send position updates when moved this much
    private float lastSendTime;
    private float sendInterval = 0.05f; // Send at most 20 times per second
    
    private void Start()
    {
        targetPosition = transform.position;
        lastSentPosition = transform.position;
    }
    
    public void SetNetworkManager(GameNetworkManager manager)
    {
        networkManager = manager;
    }
    
    private void Update()
    {
        if (networkManager == null || !networkManager.IsConnected()) return;
        
        HandleInput();
        UpdatePosition();
        CheckSendPosition();
    }
    
    private void HandleInput()
    {
        Vector3 inputDirection = Vector3.zero;
        
        if (Input.GetKey(forwardKey))
            inputDirection += Vector3.forward;
        if (Input.GetKey(backwardKey))
            inputDirection += Vector3.back;
        if (Input.GetKey(leftKey))
            inputDirection += Vector3.left;
        if (Input.GetKey(rightKey))
            inputDirection += Vector3.right;
        
        // Normalize diagonal movement
        if (inputDirection.magnitude > 1)
            inputDirection = inputDirection.normalized;
        
        // Update target position
        targetPosition += inputDirection * moveSpeed * Time.deltaTime;
    }
    
    private void UpdatePosition()
    {
        // Smooth movement to target position
        transform.position = Vector3.SmoothDamp(transform.position, targetPosition, ref velocity, smoothTime);
    }
    
    private void CheckSendPosition()
    {
        // Check if we should send position update
        float distanceMoved = Vector3.Distance(transform.position, lastSentPosition);
        float timeSinceLastSend = Time.time - lastSendTime;
        
        if (distanceMoved > positionSendThreshold || timeSinceLastSend > sendInterval)
        {
            networkManager.SendPositionUpdate(transform.position);
            lastSentPosition = transform.position;
            lastSendTime = Time.time;
        }
    }
    
    // Alternative input method using Unity's Input Manager
    private void HandleInputAlternative()
    {
        float horizontal = Input.GetAxisRaw("Horizontal");
        float vertical = Input.GetAxisRaw("Vertical");
        
        Vector3 inputDirection = new Vector3(horizontal, 0, vertical).normalized;
        targetPosition += inputDirection * moveSpeed * Time.deltaTime;
    }
    
    // Method to set position from server (for reconciliation)
    public void SetPosition(Vector3 position)
    {
        transform.position = position;
        targetPosition = position;
        lastSentPosition = position;
    }
}
